//
//  MainEditorView.swift
//  NotepadMac
//
//  Primary editor window view composing the toolbar, tab bar, editor, and status bar
//

import SwiftUI

public struct MainEditorView: View {
    @StateObject private var documentManager = DocumentManager()

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            NotepadToolbar(documentManager: documentManager)
            NotepadTabBar(documentManager: documentManager)
            findReplaceSection
            editorCoreSection
            NotepadStatusBar(documentManager: documentManager)
        }
        .frame(minWidth: 800, minHeight: 500)
        .sheet(isPresented: $documentManager.isPreferencesPresented) {
            PreferencesView(documentManager: documentManager)
        }
        .sheet(isPresented: $documentManager.isAboutPresented) {
            AboutView(documentManager: documentManager)
        }
        .sheet(isPresented: $documentManager.isFindReplaceDialogPresented) {
            FindReplaceDialogView(documentManager: documentManager)
        }
        .sheet(isPresented: $documentManager.isLuaConsolePresented) {
            LuaConsoleSheet(documentManager: documentManager)
        }
        .sheet(isPresented: $documentManager.isGoToLinePresented) {
            GoToLineSheet(documentManager: documentManager)
        }
        .applyDocumentNotifications(manager: documentManager)
        .applyFormattingNotifications(manager: documentManager)
    }

    @ViewBuilder
    private var findReplaceSection: some View {
        if documentManager.isFindReplaceBarVisible {
            FindReplaceBar(documentManager: documentManager)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var editorCoreSection: some View {
        if let doc = documentManager.activeDocument {
            ScintillaEditorRepresentable(
                text: Binding(
                    get: { doc.content },
                    set: { doc.content = $0 }
                ),
                cursorLine: Binding(
                    get: { doc.cursorLine },
                    set: { doc.cursorLine = $0 }
                ),
                cursorColumn: Binding(
                    get: { doc.cursorColumn },
                    set: { doc.cursorColumn = $0 }
                ),
                selectionLength: Binding(
                    get: { doc.selectionLength },
                    set: { doc.selectionLength = $0 }
                ),
                isModified: Binding(
                    get: { doc.isModified },
                    set: { doc.isModified = $0 }
                ),
                fontName: documentManager.fontName,
                fontSize: documentManager.fontSize,
                isWordWrapEnabled: documentManager.isWordWrapEnabled,
                showLineNumbers: documentManager.showLineNumbers,
                showFolding: documentManager.showFolding,
                showWhiteSpace: documentManager.showWhiteSpace,
                showIndentGuides: documentManager.showIndentGuides,
                theme: documentManager.activeTheme,
                language: doc.language,
                zoomOffset: doc.zoomOffset,
                documentManager: documentManager
            )
            .id(doc.id)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            emptyPlaceholderSection
        }
    }

    @ViewBuilder
    private var emptyPlaceholderSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No Document Open")
                .font(.headline)
                .foregroundColor(.secondary)
            Button("Create New Document") {
                documentManager.newDocument()
            }
            .buttonStyle(ProminentButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(documentManager.activeTheme.backgroundSwiftUIColor)
    }
}

private extension View {
    func applyDocumentNotifications(manager: DocumentManager) -> some View {
        self
            .onReceive(NotificationCenter.default.publisher(for: .notepadNewDocument)) { _ in
                manager.newDocument()
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadOpenDocument)) { _ in
                manager.promptOpenDocument()
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadSaveDocument)) { _ in
                manager.saveActiveDocument()
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadSaveAsDocument)) { _ in
                if let doc = manager.activeDocument {
                    manager.promptSaveAs(for: doc)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadSaveAllDocuments)) { _ in
                manager.saveAllDocuments()
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadCloseTab)) { _ in
                if let id = manager.activeDocumentID {
                    manager.closeDocument(id: id)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadCloseAllTabs)) { _ in
                manager.closeAllDocuments()
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadToggleFind)) { _ in
                manager.findDialogTab = 0
                manager.isFindReplaceDialogPresented = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadShowFindDialog)) { _ in
                manager.findDialogTab = 0
                manager.isFindReplaceDialogPresented = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadShowReplaceDialog)) { _ in
                manager.findDialogTab = 1
                manager.isFindReplaceDialogPresented = true
            }
    }

    func applyFormattingNotifications(manager: DocumentManager) -> some View {
        self
            .onReceive(NotificationCenter.default.publisher(for: .notepadToggleWordWrap)) { _ in
                manager.isWordWrapEnabled.toggle()
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadToggleLineNumbers)) { _ in
                manager.showLineNumbers.toggle()
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadToggleFolding)) { _ in
                manager.showFolding.toggle()
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadZoomIn)) { _ in
                manager.editorZoomIn()
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadZoomOut)) { _ in
                manager.editorZoomOut()
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadResetZoom)) { _ in
                manager.activeDocument?.zoomOffset = 0
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadSelectLanguage)) { notif in
                if let lang = notif.userInfo?["language"] as? LanguageDefinition {
                    manager.activeDocument?.language = lang
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadSelectTheme)) { notif in
                if let theme = notif.userInfo?["theme"] as? Theme {
                    manager.activeTheme = theme
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadSetLineEnding)) { notif in
                if let ending = notif.userInfo?["ending"] as? LineEnding {
                    manager.setLineEnding(ending)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadSetEncoding)) { notif in
                if let encoding = notif.userInfo?["encoding"] as? String.Encoding {
                    manager.setEncoding(encoding)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadToggleLuaConsole)) { _ in
                manager.isLuaConsolePresented.toggle()
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadShowPreferences)) { _ in
                manager.isPreferencesPresented = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadShowAbout)) { _ in
                manager.isAboutPresented = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadUseSelectionForFind)) { notif in
                if let q = notif.userInfo?["query"] as? String, !q.isEmpty {
                    manager.searchQuery = q
                    manager.isFindReplaceBarVisible = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .notepadPromptGoToLine)) { _ in
                manager.promptGoToLine()
            }
    }
}

public struct GoToLineSheet: View {
    @ObservedObject var documentManager: DocumentManager

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Go to Line")
                .font(.headline)

            HStack {
                Text("Line number:")
                    .font(.subheadline)
                TextField("Line", text: $documentManager.targetLineInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    documentManager.isGoToLinePresented = false
                }
                Button("Go") {
                    if let line = Int(documentManager.targetLineInput.trimmingCharacters(in: .whitespaces)) {
                        documentManager.goToLine(line)
                    }
                    documentManager.isGoToLinePresented = false
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 260)
    }
}
