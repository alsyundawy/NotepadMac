//
//  NotepadToolbar.swift
//  NotepadMac
//
//  Permanent dark top toolbar (#21252b) with high-productivity editor actions
//

import SwiftUI

public struct NotepadToolbar: View {
    @ObservedObject var documentManager: DocumentManager

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    public var body: some View {
        HStack(spacing: 4) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    fileGroup
                    toolbarDivider
                    clipboardGroup
                    toolbarDivider
                    searchGroup
                    toolbarDivider
                    viewGroup
                }
                .padding(.leading, 4)
            }

            Spacer(minLength: 8)

            preferencesButton
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color(red: 0.13, green: 0.15, blue: 0.17))
        .foregroundColor(.white)
    }

    // MARK: - Sub-groups

    private var fileGroup: some View {
        Group {
            ToolbarButton(icon: "doc.badge.plus", title: "New Document", shortcut: "⌘N") {
                documentManager.newDocument()
            }
            ToolbarButton(icon: "folder", title: "Open File", shortcut: "⌘O") {
                documentManager.promptOpenDocument()
            }
            ToolbarButton(icon: "square.and.arrow.down", title: "Save File", shortcut: "⌘S") {
                documentManager.saveActiveDocument()
            }
            ToolbarButton(
                icon: "square.and.arrow.down.on.square",
                title: "Save File As...",
                shortcut: "⇧⌘S"
            ) {
                if let doc = documentManager.activeDocument {
                    documentManager.promptSaveAs(for: doc)
                }
            }
            ToolbarButton(
                icon: "square.and.arrow.down.on.square.fill",
                title: "Save All Documents",
                shortcut: "⌥⌘S"
            ) {
                documentManager.saveAllDocuments()
            }
            ToolbarButton(icon: "xmark.square", title: "Close Active Tab", shortcut: "⌘W") {
                if let id = documentManager.activeDocumentID {
                    documentManager.closeDocument(id: id)
                }
            }
            ToolbarButton(icon: "xmark.square.fill", title: "Close All Tabs", shortcut: "⌥⌘W") {
                documentManager.closeAllDocuments()
            }
            ToolbarButton(icon: "printer", title: "Print Document", shortcut: "⌘P") {
                NotificationCenter.default.post(name: .notepadPrint, object: nil)
            }
        }
    }

    private var clipboardGroup: some View {
        Group {
            ToolbarButton(icon: "arrow.uturn.backward", title: "Undo", shortcut: "⌘Z") {
                NotificationCenter.default.post(name: .notepadUndo, object: nil)
            }
            ToolbarButton(icon: "arrow.uturn.forward", title: "Redo", shortcut: "⇧⌘Z") {
                NotificationCenter.default.post(name: .notepadRedo, object: nil)
            }
            ToolbarButton(icon: "scissors", title: "Cut", shortcut: "⌘X") {
                NotificationCenter.default.post(name: .notepadCut, object: nil)
            }
            ToolbarButton(icon: "doc.on.doc", title: "Copy", shortcut: "⌘C") {
                NotificationCenter.default.post(name: .notepadCopy, object: nil)
            }
            ToolbarButton(icon: "doc.on.clipboard", title: "Paste", shortcut: "⌘V") {
                NotificationCenter.default.post(name: .notepadPaste, object: nil)
            }
            ToolbarButton(icon: "increase.indent", title: "Indent Selection", shortcut: "Tab") {
                NotificationCenter.default.post(name: .notepadIndent, object: nil)
            }
            ToolbarButton(icon: "decrease.indent", title: "Outdent Selection", shortcut: "⇧Tab") {
                NotificationCenter.default.post(name: .notepadOutdent, object: nil)
            }
            ToolbarButton(icon: "plus.square.on.square", title: "Duplicate Current Line", shortcut: "⌘D") {
                NotificationCenter.default.post(name: .notepadDuplicateLine, object: nil)
            }
            ToolbarButton(icon: "trash", title: "Delete Current Line", shortcut: "⇧⌘K") {
                NotificationCenter.default.post(name: .notepadDeleteLine, object: nil)
            }
            ToolbarButton(icon: "calendar.badge.clock", title: "Insert Date / Time", shortcut: "F5") {
                NotificationCenter.default.post(name: .notepadInsertDateTime, object: nil)
            }
        }
    }

    private var searchGroup: some View {
        Group {
            ToolbarButton(
                icon: "magnifyingglass",
                title: "Find Dialog",
                shortcut: "⌘F",
                isActive: documentManager.isFindReplaceDialogPresented && documentManager.findDialogTab == 0
            ) {
                documentManager.findDialogTab = 0
                documentManager.isFindReplaceDialogPresented = true
            }
            ToolbarButton(
                icon: "arrow.triangle.2.circlepath",
                title: "Find & Replace Dialog",
                shortcut: "⌥⌘F",
                isActive: documentManager.isFindReplaceDialogPresented && documentManager.findDialogTab == 1
            ) {
                documentManager.findDialogTab = 1
                documentManager.isFindReplaceDialogPresented = true
            }
            ToolbarButton(
                icon: "character.magnifyingglass",
                title: "Toggle In-Editor Find Bar",
                shortcut: "⇧⌘F",
                isActive: documentManager.isFindReplaceBarVisible
            ) {
                withAnimation {
                    documentManager.isFindReplaceBarVisible.toggle()
                }
            }
            ToolbarButton(icon: "chevron.down.circle", title: "Find Next Match", shortcut: "⌘G") {
                NotificationCenter.default.post(name: .notepadFindNext, object: nil)
            }
            ToolbarButton(icon: "chevron.up.circle", title: "Find Previous Match", shortcut: "⇧⌘G") {
                NotificationCenter.default.post(name: .notepadFindPrevious, object: nil)
            }
            ToolbarButton(icon: "arrow.right.to.line", title: "Go to Line...", shortcut: "⌘L") {
                documentManager.isGoToLinePresented = true
            }
        }
    }

    private var viewGroup: some View {
        Group {
            ToolbarButton(
                icon: "text.word.spacing",
                title: "Toggle Word Wrap",
                shortcut: "⌥Z",
                isActive: documentManager.isWordWrapEnabled
            ) {
                documentManager.isWordWrapEnabled.toggle()
            }
            ToolbarButton(
                icon: "list.number",
                title: "Toggle Line Numbers",
                isActive: documentManager.showLineNumbers
            ) {
                documentManager.showLineNumbers.toggle()
            }
            ToolbarButton(
                icon: "sidebar.squares.left",
                title: "Toggle Code Folding",
                isActive: documentManager.showFolding
            ) {
                documentManager.showFolding.toggle()
            }
            ToolbarButton(
                icon: "paragraphsign",
                title: "Toggle White Space & EOL",
                isActive: documentManager.showWhiteSpace
            ) {
                documentManager.showWhiteSpace.toggle()
            }
            ToolbarButton(
                icon: "ruler",
                title: "Toggle Indentation Guides",
                isActive: documentManager.showIndentGuides
            ) {
                documentManager.showIndentGuides.toggle()
            }
            ToolbarButton(icon: "minus.magnifyingglass", title: "Zoom Out", shortcut: "⌘-") {
                documentManager.activeDocument?.zoomOffset -= 1
            }
            if let doc = documentManager.activeDocument {
                let zoomPercent = max(10, 100 + doc.zoomOffset * 10)
                Text("\(zoomPercent)%")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(white: 0.8))
                    .frame(minWidth: 32)
                    .help("Current Zoom Level: \(zoomPercent)% (⌘0 to reset)")
            }
            ToolbarButton(icon: "plus.magnifyingglass", title: "Zoom In", shortcut: "⌘+") {
                documentManager.activeDocument?.zoomOffset += 1
            }
            ToolbarButton(icon: "equal.circle", title: "Reset Zoom to 100%", shortcut: "⌘0") {
                documentManager.activeDocument?.zoomOffset = 0
            }
        }
    }

    private var preferencesButton: some View {
        ToolbarButton(
            icon: "gearshape",
            title: "Preferences & Settings",
            shortcut: "⌘,",
            isActive: documentManager.isPreferencesPresented
        ) {
            documentManager.isPreferencesPresented.toggle()
        }
    }

    private var toolbarDivider: some View {
        Divider()
            .frame(height: 16)
            .background(Color.white.opacity(0.18))
            .padding(.horizontal, 2)
    }
}

public struct ToolbarButton: View {
    public let icon: String
    public let title: String
    public var shortcut: String?
    public var isActive: Bool = false
    public let action: () -> Void

    @State private var isHovering: Bool = false

    private var buttonBgColor: Color {
        if isActive {
            return Color.blue.opacity(0.2)
        }
        if isHovering {
            return Color.white.opacity(0.1)
        }
        return Color.clear
    }

    private var iconColor: Color {
        if isActive {
            return .blue
        }
        return isHovering ? .white : Color(white: 0.8)
    }

    private var tooltipText: String {
        if let sc = shortcut, !sc.isEmpty {
            return "\(title) (\(sc))"
        }
        return title
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 26, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(buttonBgColor)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovering = $0 }
        .help(tooltipText)
    }
}
