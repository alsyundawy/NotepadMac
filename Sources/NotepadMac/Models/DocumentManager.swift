/*
 *
 * This file is part of NotepadMac.
 *
 * Copyright 2025-2026 Harry Dertin Sutisna Alsyundawy <alsyundawy@gmail.com>
 * https://github.com/alsyundawy/NotepadMac
 * ALSYUNDAWY IT SOLUTION <https://alsyundawy.com>
 *
 * NotepadMac is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * NotepadMac is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with NotepadMac.  If not, see <https://www.gnu.org/licenses/>.
 */

import AppKit
import SwiftUI

public final class DocumentManager: ObservableObject, EditorActionDelegate {
    public static weak var mainInstance: DocumentManager?

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
    @Published public var isAutocompletionEnabled: Bool = false

    // UI Panel toggles
    @Published public var isFindReplaceBarVisible: Bool = false
    @Published public var isFindReplaceDialogPresented: Bool = false
    @Published public var findDialogTab: Int = 0
    @Published public var isLuaConsolePresented: Bool = false
    @Published public var isPreferencesPresented: Bool = false
    @Published public var isAboutPresented: Bool = false
    @Published public var isGoToLinePresented: Bool = false
    @Published public var isToolsDialogPresented: Bool = false
    @Published public var toolsDialogTab: Int = 0
    @Published public var isCheckUpdatePresented: Bool = false
    @Published public var targetLineInput: String = ""

    // Autosave & Crash Recovery
    public let recoveryManager = AutosaveRecoveryManager()
    @Published public var isCrashRecoveryPresented: Bool = false
    @Published public var pendingRecoverySnapshots: [RecoverySnapshot] = []

    // Rename Tab & Coloring state
    @Published public var isRenameTabPresented: Bool = false
    @Published public var documentToRename: EditorDocument?
    @Published public var renameTabInput: String = ""
    @Published public var renameTabError: String?
    @Published public var renameTabColorHex: String?

    // Formatting & Indentation Preferences
    @Published public var tabIndentSpaces: Int = 4
    @Published public var useSpacesForTab: Bool = true

    // Search state
    @Published public var searchQuery: String = ""
    @Published public var replaceQuery: String = ""
    @Published public var isMatchCase: Bool = false
    @Published public var isWholeWord: Bool = false
    @Published public var isRegex: Bool = false
    @Published public var isWrapAround: Bool = true
    @Published public var searchDirectionUp: Bool = false
    @Published public var isBookmarkLine: Bool = true
    @Published public var isPurgeOnSearch: Bool = true
    @Published public var searchStatus: String = ""

    public let luaEngine = LuaEngine()

    public init() {
        DocumentManager.mainInstance = self
        // Create an initial default empty document
        newDocument()
        startAutosaveTimer()
    }

    private func startAutosaveTimer() {
        recoveryManager.start { [weak self] in
            self?.documents ?? []
        }
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
            let detectedLanguage = LexerRegistry.shared.detectLanguage(
                forFilename: url.lastPathComponent,
                content: content
            )
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

    @discardableResult
    public func saveDocument(_ doc: EditorDocument, to url: URL) -> Bool {
        do {
            guard let data = doc.content.data(using: doc.encoding) else {
                throw NSError(domain: "NotepadMac", code: 1, userInfo: [NSLocalizedDescriptionKey: "Encoding error"])
            }
            try data.write(to: url, options: .atomic)
            doc.fileURL = url
            doc.title = url.lastPathComponent
            doc.isModified = false
            doc.language = LexerRegistry.shared.detectLanguage(
                forFilename: url.lastPathComponent,
                content: doc.content
            )
            recoveryManager.removeSnapshot(for: doc.id)
            return true
        } catch {
            print("Failed to save document to \(url): \(error.localizedDescription)")
            return false
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

    @discardableResult
    public func promptSaveAsModal(for doc: EditorDocument, window: NSWindow? = nil) -> Bool {
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = doc.title
        savePanel.canCreateDirectories = true

        let response = savePanel.runModal()
        if response == .OK, let targetURL = savePanel.url {
            return saveDocument(doc, to: targetURL)
        }
        return false
    }

    /// Prompts the user when closing a document with unsaved changes.
    /// Returns true if it is safe to proceed with closing, or false if the user cancelled.
    public func confirmCloseDocument(_ doc: EditorDocument, window: NSWindow? = nil) -> Bool {
        guard doc.isModified else { return true }

        let alert = NSAlert()
        alert.alertStyle = .warning
        let titleFormat = loc("save_changes_title")
        alert.messageText = String(format: titleFormat, doc.title)
        alert.informativeText = loc("save_changes_message")

        let saveBtn = alert.addButton(withTitle: loc("save"))
        saveBtn.keyEquivalent = "\r"

        let cancelBtn = alert.addButton(withTitle: loc("cancel"))
        cancelBtn.keyEquivalent = "\u{1b}"

        let dontSaveBtn = alert.addButton(withTitle: loc("dont_save"))
        dontSaveBtn.keyEquivalent = "d"
        dontSaveBtn.keyEquivalentModifierMask = .command

        let response = alert.runModal()

        switch response {
        case .alertFirstButtonReturn:
            // User chose Save
            if let url = doc.fileURL {
                return saveDocument(doc, to: url)
            } else {
                return promptSaveAsModal(for: doc, window: window)
            }
        case .alertSecondButtonReturn:
            // User chose Cancel
            return false
        case .alertThirdButtonReturn:
            // User chose Don't Save
            return true
        default:
            return false
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

    @discardableResult
    public func closeDocument(id: UUID) -> Bool {
        guard let index = documents.firstIndex(where: { $0.id == id }) else { return true }
        let doc = documents[index]

        if doc.isModified {
            activeDocumentID = doc.id
            if !confirmCloseDocument(doc) {
                return false
            }
        }

        documents.remove(at: index)
        recoveryManager.removeSnapshot(for: id)

        if activeDocumentID == id {
            if documents.indices.contains(index) {
                activeDocumentID = documents[index].id
            } else if let last = documents.last {
                activeDocumentID = last.id
            } else {
                newDocument()
            }
        }
        return true
    }

    @discardableResult
    public func closeOtherDocuments(except id: UUID) -> Bool {
        let others = documents.filter { $0.id != id }
        for doc in others where doc.isModified {
            activeDocumentID = doc.id
            if !confirmCloseDocument(doc) {
                return false
            }
        }
        for doc in others {
            recoveryManager.removeSnapshot(for: doc.id)
        }
        documents.removeAll(where: { $0.id != id })
        activeDocumentID = id
        return true
    }

    @discardableResult
    public func closeTabsToTheRight(of id: UUID) -> Bool {
        guard let index = documents.firstIndex(where: { $0.id == id }) else { return true }
        let rightDocs = Array(documents.suffix(from: index + 1))
        for doc in rightDocs where doc.isModified {
            activeDocumentID = doc.id
            if !confirmCloseDocument(doc) {
                return false
            }
        }
        for doc in rightDocs {
            recoveryManager.removeSnapshot(for: doc.id)
        }
        if index + 1 < documents.count {
            documents.removeSubrange((index + 1)...)
            if let activeID = activeDocumentID, !documents.contains(where: { $0.id == activeID }) {
                activeDocumentID = id
            }
        }
        return true
    }

    public func saveAllDocuments() {
        for doc in documents {
            if let url = doc.fileURL {
                saveDocument(doc, to: url)
            } else if doc.isModified {
                promptSaveAs(for: doc)
            }
        }
    }

    @discardableResult
    public func closeAllDocuments() -> Bool {
        for doc in documents where doc.isModified {
            activeDocumentID = doc.id
            if !confirmCloseDocument(doc) {
                return false
            }
        }
        documents.removeAll()
        recoveryManager.clearAllSnapshots()
        newDocument()
        return true
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

    public func zoomIn() {
        NotificationCenter.default.post(name: .notepadZoomIn, object: nil)
    }

    public func zoomOut() {
        NotificationCenter.default.post(name: .notepadZoomOut, object: nil)
    }

    public func resetZoom() {
        NotificationCenter.default.post(name: .notepadResetZoom, object: nil)
    }

    public func editorZoomIn() {
        DispatchQueue.main.async { [weak self] in
            self?.zoomIn()
        }
    }

    public func editorZoomOut() {
        DispatchQueue.main.async { [weak self] in
            self?.zoomOut()
        }
    }

    public func openToolsDialog(tab: Int = 0) {
        toolsDialogTab = tab
        isToolsDialogPresented = true
    }

    public func showCheckForUpdates() {
        isCheckUpdatePresented = true
    }

    // MARK: - Crash Recovery Operations

    public func checkPendingRecoverySnapshots() {
        let snapshots = recoveryManager.loadPendingSnapshots()
        if !snapshots.isEmpty {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.pendingRecoverySnapshots = snapshots
                self.isCrashRecoveryPresented = true
            }
        }
    }

    public func recoverSnapshots(_ snapshots: [RecoverySnapshot]) {
        for snapshot in snapshots {
            let fileURL = snapshot.originalPath.map { URL(fileURLWithPath: $0) }
            let detectedLanguage = LexerRegistry.shared.detectLanguage(
                forFilename: snapshot.originalPath != nil ? (fileURL?.lastPathComponent ?? snapshot.title) : snapshot.title,
                content: snapshot.content
            )
            let detectedLineEnding = LineEnding.detect(in: snapshot.content)

            let doc = EditorDocument(
                title: snapshot.title,
                fileURL: fileURL,
                content: snapshot.content,
                isModified: true,
                lineEnding: detectedLineEnding,
                language: detectedLanguage,
                cursorLine: snapshot.cursorLine
            )

            // If the only existing document is an untouched empty "New 1", replace it
            if documents.count == 1,
               let first = documents.first,
               first.fileURL == nil,
               !first.isModified,
               first.content.isEmpty {
                documents = [doc]
                activeDocumentID = doc.id
            } else {
                documents.append(doc)
                activeDocumentID = doc.id
            }

            // Remove snapshot file once recovered into memory
            recoveryManager.removeSnapshot(for: snapshot.documentId)
        }

        // Refresh pending list
        pendingRecoverySnapshots.removeAll(where: { snapshot in
            snapshots.contains(where: { $0.id == snapshot.id })
        })

        if pendingRecoverySnapshots.isEmpty {
            isCrashRecoveryPresented = false
        }
    }

    public func discardRecoverySnapshots(_ snapshots: [RecoverySnapshot]) {
        for snapshot in snapshots {
            recoveryManager.removeSnapshot(for: snapshot.documentId)
        }
        pendingRecoverySnapshots.removeAll(where: { snapshot in
            snapshots.contains(where: { $0.id == snapshot.id })
        })
        if pendingRecoverySnapshots.isEmpty {
            isCrashRecoveryPresented = false
        }
    }

    public func discardAllRecoverySnapshots() {
        recoveryManager.clearAllSnapshots()
        pendingRecoverySnapshots.removeAll()
        isCrashRecoveryPresented = false
    }

    // MARK: - Tab Rename & Color Operations

    public func promptRenameDocument(_ doc: EditorDocument) {
        documentToRename = doc
        renameTabInput = doc.title
        renameTabError = nil
        renameTabColorHex = doc.tagColorHex
        isRenameTabPresented = true
    }

    public func promptRenameActiveDocument() {
        guard let doc = activeDocument else { return }
        promptRenameDocument(doc)
    }

    public func setTabColor(for doc: EditorDocument, colorHex: String?) {
        doc.tagColorHex = colorHex
    }

    @discardableResult
    public func applyRenameDocument() -> Bool {
        guard let doc = documentToRename else { return false }
        let trimmed = renameTabInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            renameTabError = loc("title_empty_error")
            return false
        }

        // Apply updated color tag if modified
        doc.tagColorHex = renameTabColorHex

        // If title hasn't changed, simply close
        if trimmed == doc.title {
            isRenameTabPresented = false
            return true
        }

        // If document is backed by a physical file on disk, rename the actual file
        if let currentURL = doc.fileURL {
            let directory = currentURL.deletingLastPathComponent()
            let newURL = directory.appendingPathComponent(trimmed)

            if newURL.path != currentURL.path && FileManager.default.fileExists(atPath: newURL.path) {
                renameTabError = loc("file_exists_error")
                return false
            }

            do {
                try FileManager.default.moveItem(at: currentURL, to: newURL)
                doc.fileURL = newURL
                doc.title = trimmed
                doc.language = LexerRegistry.shared.detectLanguage(
                    forFilename: trimmed,
                    content: doc.content
                )

                // Update recovery snapshot to reflect new title/path
                recoveryManager.removeSnapshot(for: doc.id)
                if doc.isModified {
                    recoveryManager.saveSnapshot(for: doc)
                }

                isRenameTabPresented = false
                return true
            } catch {
                renameTabError = String(format: loc("rename_failed_error"), error.localizedDescription)
                return false
            }
        } else {
            // Untitled in-memory document
            doc.title = trimmed
            doc.language = LexerRegistry.shared.detectLanguage(
                forFilename: trimmed,
                content: doc.content
            )

            // Update recovery snapshot if modified
            if doc.isModified {
                recoveryManager.saveSnapshot(for: doc)
            }

            isRenameTabPresented = false
            return true
        }
    }
}
