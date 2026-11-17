//
//  DocumentManager.swift
//  NotepadMac
//
//  Multi-tab document manager and editor coordinator
//

import AppKit
import SwiftUI

public final class DocumentManager: ObservableObject, EditorActionDelegate {
    @Published public var documents: [EditorDocument] = []
    @Published public var activeDocumentID: UUID?

    // Global editor preferences
    @Published public var activeTheme: Theme = .sparkNotepadLight
    @Published public var fontName: String = "Menlo"
    @Published public var fontSize: Int = 13
    @Published public var isWordWrapEnabled: Bool = false
    @Published public var showLineNumbers: Bool = true
    @Published public var showFolding: Bool = true
    @Published public var showWhiteSpace: Bool = false
    @Published public var showIndentGuides: Bool = true

    // UI Panel toggles
    @Published public var isFindReplaceBarVisible: Bool = false
    @Published public var isFindReplaceDialogPresented: Bool = false
    @Published public var findDialogTab: Int = 0
    @Published public var isLuaConsolePresented: Bool = false
    @Published public var isPreferencesPresented: Bool = false
    @Published public var isAboutPresented: Bool = false
    @Published public var isGoToLinePresented: Bool = false
    @Published public var targetLineInput: String = ""

    // Search state
    @Published public var searchQuery: String = ""
    @Published public var replaceQuery: String = ""
    @Published public var isMatchCase: Bool = false
    @Published public var isWholeWord: Bool = false
    @Published public var isRegex: Bool = false
    @Published public var isWrapAround: Bool = true
    @Published public var searchDirectionUp: Bool = false
    @Published public var searchStatus: String = ""

    public let luaEngine = LuaEngine()

    public init() {
        // Create an initial default empty document
        newDocument()
    }

    public var activeDocument: EditorDocument? {
        get {
            guard let id = activeDocumentID else { return documents.first }
            return documents.first(where: { $0.id == id }) ?? documents.first
        }
        set {
            activeDocumentID = newValue?.id
        }
    }

    // MARK: - Document Actions

    @discardableResult
    public func newDocument(title: String? = nil, content: String = "") -> EditorDocument {
        let count = documents.count + 1
        let docTitle = title ?? "New \(count)"
        let doc = EditorDocument(
            title: docTitle,
            content: content,
            language: LexerRegistry.shared.plainTextLanguage
        )
        documents.append(doc)
        activeDocumentID = doc.id
        return doc
    }

    public func openDocument(from url: URL) {
        // Check if already open
        if let existing = documents.first(where: { $0.fileURL == url }) {
            activeDocumentID = existing.id
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let encoding: String.Encoding = .utf8
            let content = String(bytes: data, encoding: encoding) ?? ""
            let detectedLanguage = LexerRegistry.shared.language(forExtension: url.pathExtension)
            let detectedLineEnding = LineEnding.detect(in: content)

            let doc = EditorDocument(
                title: url.lastPathComponent,
                fileURL: url,
                content: content,
                isModified: false,
                encoding: encoding,
                lineEnding: detectedLineEnding,
                language: detectedLanguage
            )
            documents.append(doc)
            activeDocumentID = doc.id
        } catch {
            print("Failed to open document at \(url): \(error.localizedDescription)")
        }
    }

    public func saveActiveDocument() {
        guard let doc = activeDocument else { return }
        if let url = doc.fileURL {
            saveDocument(doc, to: url)
        } else {
            promptSaveAs(for: doc)
        }
    }

    public func saveDocument(_ doc: EditorDocument, to url: URL) {
        do {
            guard let data = doc.content.data(using: doc.encoding) else {
                throw NSError(domain: "NotepadMac", code: 1, userInfo: [NSLocalizedDescriptionKey: "Encoding error"])
            }
            try data.write(to: url, options: .atomic)
            doc.fileURL = url
            doc.title = url.lastPathComponent
            doc.isModified = false
            doc.language = LexerRegistry.shared.language(forExtension: url.pathExtension)
        } catch {
            print("Failed to save document to \(url): \(error.localizedDescription)")
        }
    }

    public func promptSaveAs(for doc: EditorDocument) {
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = doc.title
        savePanel.canCreateDirectories = true

        savePanel.begin { [weak self] response in
            if response == .OK, let targetURL = savePanel.url {
                self?.saveDocument(doc, to: targetURL)
            }
        }
    }

    public func promptOpenDocument() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = true

        openPanel.begin { [weak self] response in
            if response == .OK {
                for url in openPanel.urls {
                    self?.openDocument(from: url)
                }
            }
        }
    }

    public func closeDocument(id: UUID) {
        guard let index = documents.firstIndex(where: { $0.id == id }) else { return }
        documents.remove(at: index)

        if activeDocumentID == id {
            if documents.indices.contains(index) {
                activeDocumentID = documents[index].id
            } else if let last = documents.last {
                activeDocumentID = last.id
            } else {
                newDocument()
            }
        }
    }

    public func closeOtherDocuments(except id: UUID) {
        documents.removeAll(where: { $0.id != id })
        activeDocumentID = id
    }

    public func saveAllDocuments() {
        for doc in documents {
            if let url = doc.fileURL {
                saveDocument(doc, to: url)
            }
        }
    }

    public func closeAllDocuments() {
        documents.removeAll()
        newDocument()
    }

    public func duplicateLine() {
        NotificationCenter.default.post(name: .notepadDuplicateLine, object: nil)
    }

    public func deleteLine() {
        NotificationCenter.default.post(name: .notepadDeleteLine, object: nil)
    }

    public func makeUpperCase() {
        NotificationCenter.default.post(name: .notepadMakeUpperCase, object: nil)
    }

    public func makeLowerCase() {
        NotificationCenter.default.post(name: .notepadMakeLowerCase, object: nil)
    }

    public func capitalizeText() {
        NotificationCenter.default.post(name: .notepadCapitalize, object: nil)
    }

    public func insertDateTime() {
        NotificationCenter.default.post(name: .notepadInsertDateTime, object: nil)
    }

    public func goToLine(_ line: Int) {
        NotificationCenter.default.post(name: .notepadGoToLine, object: nil, userInfo: ["line": line])
    }

    public func promptGoToLine() {
        targetLineInput = "\(activeDocument?.cursorLine ?? 1)"
        isGoToLinePresented = true
    }

    public func setLineEnding(_ ending: LineEnding) {
        guard let doc = activeDocument else { return }
        doc.lineEnding = ending
        let normalized = doc.content
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        doc.content = normalized.replacingOccurrences(of: "\n", with: ending.separator)
        doc.isModified = true
    }

    public func setEncoding(_ encoding: String.Encoding) {
        guard let doc = activeDocument else { return }
        doc.encoding = encoding
        doc.isModified = true
    }

    // MARK: - EditorActionDelegate (Lua Bridge)

    public func editorGetText() -> String {
        return activeDocument?.content ?? ""
    }

    public func editorSetText(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let doc = self?.activeDocument else { return }
            doc.content = text
            doc.isModified = true
        }
    }

    public func editorGetSelection() -> String {
        // Selection text proxy
        return ""
    }

    public func editorReplaceSelection(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let doc = self?.activeDocument else { return }
            doc.content += text
            doc.isModified = true
        }
    }

    public func editorGetLineCount() -> Int {
        return activeDocument?.lineCount ?? 1
    }

    public func editorGetCurrentLine() -> Int {
        return activeDocument?.cursorLine ?? 1
    }

    public func editorInsertText(at position: Int, text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let doc = self?.activeDocument else { return }
            var current = doc.content
            let idx = current.index(current.startIndex, offsetBy: min(position, current.count))
            current.insert(contentsOf: text, at: idx)
            doc.content = current
            doc.isModified = true
        }
    }

    public func editorClear() {
        DispatchQueue.main.async { [weak self] in
            self?.activeDocument?.content = ""
            self?.activeDocument?.isModified = true
        }
    }

    public func editorZoomIn() {
        DispatchQueue.main.async { [weak self] in
            self?.activeDocument?.zoomOffset += 1
        }
    }

    public func editorZoomOut() {
        DispatchQueue.main.async { [weak self] in
            self?.activeDocument?.zoomOffset = max(-10, (self?.activeDocument?.zoomOffset ?? 0) - 1)
        }
    }
}
