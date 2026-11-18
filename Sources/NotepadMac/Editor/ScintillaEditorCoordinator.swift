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
import ScintillaCocoa

public final class ScintillaEditorCoordinator: NSObject, ScintillaNotificationProtocol {
    var parent: ScintillaEditorRepresentable
    weak var scintillaView: ScintillaView?
    var isUpdatingFromScintilla = false

    var lastThemeID: String = ""
    var lastLanguageID: String = ""
    var lastFontName: String = ""
    var lastFontSize: Int = 0

    var observers: [NSObjectProtocol] = []

    init(_ parent: ScintillaEditorRepresentable) {
        self.parent = parent
        super.init()
        setupNotificationObservers()
    }

    deinit {
        for obs in observers {
            NotificationCenter.default.removeObserver(obs)
        }
    }

    private func setupNotificationObservers() {
        let center = NotificationCenter.default
        registerHistoryObservers(center: center)
        registerClipboardObservers(center: center)
        registerTextTransformObservers(center: center)
        registerNavigationObservers(center: center)
        registerSearchObservers(center: center)
    }

    private func registerHistoryObservers(center: NotificationCenter) {
        observers.append(center.addObserver(
            forName: .notepadUndo,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2176))
        })
        observers.append(center.addObserver(
            forName: .notepadRedo,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2011))
        })
        observers.append(center.addObserver(
            forName: .notepadSelectAll,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2013))
        })
    }

    private func registerClipboardObservers(center: NotificationCenter) {
        observers.append(center.addObserver(
            forName: .notepadCut,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2177))
        })
        observers.append(center.addObserver(
            forName: .notepadCopy,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2178))
        })
        observers.append(center.addObserver(
            forName: .notepadPaste,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2179))
        })
        observers.append(center.addObserver(
            forName: .notepadIndent,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2327))
        })
        observers.append(center.addObserver(
            forName: .notepadOutdent,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2328))
        })
        observers.append(center.addObserver(
            forName: .notepadDuplicateLine,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2404))
        })
        observers.append(center.addObserver(
            forName: .notepadDeleteLine,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2338))
        })
    }

    private func registerTextTransformObservers(center: NotificationCenter) {
        observers.append(center.addObserver(
            forName: .notepadMakeUpperCase,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleUpperCase()
        })
        observers.append(center.addObserver(
            forName: .notepadMakeLowerCase,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleLowerCase()
        })
        observers.append(center.addObserver(
            forName: .notepadCapitalize,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleCapitalize()
        })
        observers.append(center.addObserver(
            forName: .notepadInvertCase,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleInvertCase()
        })
        observers.append(center.addObserver(
            forName: .notepadInsertDateTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleInsertDateTime()
        })
    }

    private func registerNavigationObservers(center: NotificationCenter) {
        observers.append(center.addObserver(
            forName: .notepadGoToLine,
            object: nil,
            queue: .main
        ) { [weak self] notif in
            guard let view = self?.scintillaView,
                  let line = notif.userInfo?["line"] as? Int else { return }
            let target = max(0, line - 1)
            view.message(UInt32(2024), wParam: UInt(target))
            view.message(UInt32(2169))
        })
        observers.append(center.addObserver(
            forName: .notepadZoomIn,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2333))
        })
        observers.append(center.addObserver(
            forName: .notepadZoomOut,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2334))
        })
        observers.append(center.addObserver(
            forName: .notepadResetZoom,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scintillaView?.message(UInt32(2373), wParam: 0)
        })
        observers.append(center.addObserver(
            forName: .notepadToggleWhiteSpace,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.parent.documentManager?.showWhiteSpace.toggle()
        })
        observers.append(center.addObserver(
            forName: .notepadToggleIndentGuides,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.parent.documentManager?.showIndentGuides.toggle()
        })
        observers.append(center.addObserver(
            forName: .notepadPrint,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let view = self?.scintillaView else { return }
            let text = view.string() ?? ""
            let printTextView = NSTextView(frame: NSRect(x: 0, y: 0, width: 468, height: 648))
            printTextView.string = text
            printTextView.font = NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)
            let printOp = NSPrintOperation(view: printTextView, printInfo: .shared)
            printOp.showsPrintPanel = true
            printOp.run()
        })
        observers.append(center.addObserver(
            forName: .notepadPageSetup,
            object: nil,
            queue: .main
        ) { _ in
            NSApp.sendAction(#selector(NSApplication.runPageLayout(_:)), to: nil, from: nil)
        })
    }

    private func handleUpperCase() {
        guard let view = scintillaView else { return }
        ensureSelectionOrSelectWord(view: view)
        view.message(UInt32(2341)) // SCI_UPPERCASE
    }

    private func handleLowerCase() {
        guard let view = scintillaView else { return }
        ensureSelectionOrSelectWord(view: view)
        view.message(UInt32(2340)) // SCI_LOWERCASE
    }

    private func handleCapitalize() {
        guard let view = scintillaView else { return }
        ensureSelectionOrSelectWord(view: view)
        transformSelection(view: view) { $0.capitalized }
    }

    private func handleInvertCase() {
        guard let view = scintillaView else { return }
        ensureSelectionOrSelectWord(view: view)
        transformSelection(view: view) { str in
            String(str.map { char in
                char.isUppercase ? Character(char.lowercased()) : Character(char.uppercased())
            })
        }
    }

    private func ensureSelectionOrSelectWord(view: ScintillaView) {
        let start = view.message(UInt32(2143))
        let end = view.message(UInt32(2145))
        if end <= start {
            let pos = view.message(UInt32(SCI_GETCURRENTPOS))
            let wStart = view.message(UInt32(2266), wParam: UInt(pos), lParam: 1)
            let wEnd = view.message(UInt32(2267), wParam: UInt(pos), lParam: 1)
            if wEnd > wStart {
                _ = view.message(UInt32(2160), wParam: UInt(wStart), lParam: wEnd)
            }
        }
    }

    private func transformSelection(view: ScintillaView, transform: (String) -> String) {
        let text = view.string() ?? ""
        let start = view.message(UInt32(2143))
        let end = view.message(UInt32(2145))
        guard end > start else { return }

        let utf8 = text.utf8
        let startIdx = utf8.index(
            utf8.startIndex,
            offsetBy: Int(start),
            limitedBy: utf8.endIndex
        ) ?? utf8.startIndex
        let endIdx = utf8.index(
            utf8.startIndex,
            offsetBy: Int(end),
            limitedBy: utf8.endIndex
        ) ?? utf8.endIndex

        guard let selected = String(utf8[startIdx..<endIdx]) else { return }
        let result = transform(selected)
        result.withCString { cStr in
            _ = view.message(UInt32(2170), wParam: 0, lParam: Int(bitPattern: cStr))
        }
        let newEnd = start + result.utf8.count
        _ = view.message(UInt32(2160), wParam: UInt(start), lParam: newEnd)
    }

    private func handleInsertDateTime() {
        guard let view = scintillaView else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.string(from: Date())
        dateStr.withCString { cStr in
            _ = view.message(UInt32(2170), wParam: 0, lParam: Int(bitPattern: cStr))
        }
    }
}

// MARK: - Scintilla Event Handling

extension ScintillaEditorCoordinator {
    public func notification(_ notification: UnsafeMutablePointer<SCNotification>?) {
        guard let notif = notification?.pointee, let view = scintillaView else { return }
        let code = notif.nmhdr.code

        if code == 2008 {
            handleModifiedNotification(notif: notif, view: view)
        } else if code == 2001 {
            handleCharAddedNotification(ch: notif.ch, view: view)
        } else if code == 2007 {
            handleUpdateUINotification(view: view)
        } else if code == 2010 {
            handleMarginClickNotification(notif: notif, view: view)
        } else if code == 2011 {
            DispatchQueue.main.async { [weak self] in self?.parent.isModified = false }
        } else if code == 2012 {
            DispatchQueue.main.async { [weak self] in self?.parent.isModified = true }
        }
    }

    private func handleModifiedNotification(notif: SCNotification, view: ScintillaView) {
        let mask: Int32 = 0x1 | 0x2
        guard (notif.modificationType & mask) != 0 else { return }

        isUpdatingFromScintilla = true
        let newText = view.string() ?? ""
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.parent.text = newText
            let modify = view.message(UInt32(SCI_GETMODIFY))
            self.parent.isModified = (modify != 0)
            self.isUpdatingFromScintilla = false
        }
    }

    private func handleUpdateUINotification(view: ScintillaView) {
        let currentPos = view.message(UInt32(SCI_GETCURRENTPOS))
        let line = view.message(UInt32(SCI_LINEFROMPOSITION), wParam: UInt(currentPos))
        let col = view.message(UInt32(SCI_GETCOLUMN), wParam: UInt(currentPos))
        let selStart = view.message(UInt32(SCI_GETSELECTIONSTART))
        let selEnd = view.message(UInt32(SCI_GETSELECTIONEND))
        let selLen = abs(selEnd - selStart)

        updateBraceMatching(view: view, currentPos: currentPos)
        updateSmartHighlighting(view: view, selStart: selStart, selEnd: selEnd)

        DispatchQueue.main.async { [weak self] in
            self?.parent.cursorLine = line + 1
            self?.parent.cursorColumn = col + 1
            self?.parent.selectionLength = selLen
        }
    }

    private func updateSmartHighlighting(view: ScintillaView, selStart: Int, selEnd: Int) {
        if selEnd > selStart {
            let selLen = selEnd - selStart
            if selLen >= 2 && selLen <= 120, let fullText = view.string() {
                let utf8 = fullText.utf8
                let startIdx = utf8.index(
                    utf8.startIndex,
                    offsetBy: selStart,
                    limitedBy: utf8.endIndex
                ) ?? utf8.startIndex
                let endIdx = utf8.index(
                    utf8.startIndex,
                    offsetBy: selEnd,
                    limitedBy: utf8.endIndex
                ) ?? utf8.endIndex
                if let selected = String(utf8[startIdx..<endIdx]), !selected.contains("\n") {
                    highlightOccurrences(of: selected, matchCase: true)
                    return
                }
            }
        }
        if let query = parent.documentManager?.searchQuery, !query.isEmpty {
            highlightOccurrences(
                of: query,
                matchCase: parent.documentManager?.isMatchCase ?? false
            )
        } else {
            clearHighlights()
        }
    }

    private func updateBraceMatching(view: ScintillaView, currentPos: Int) {
        guard currentPos > 0 else { return }
        let bracePos = view.message(UInt32(2353), wParam: UInt(currentPos - 1))
        if bracePos >= 0 {
            view.message(UInt32(2351), wParam: UInt(currentPos - 1), lParam: bracePos)
        } else {
            view.message(UInt32(2351), wParam: UInt(bitPattern: -1), lParam: -1)
        }
    }

    private func handleMarginClickNotification(notif: SCNotification, view: ScintillaView) {
        guard notif.margin == 2 else { return }
        let line = view.message(UInt32(SCI_LINEFROMPOSITION), wParam: UInt(notif.position))
        view.message(UInt32(SCI_TOGGLEFOLD), wParam: UInt(line))
    }

    private func handleCharAddedNotification(ch: Int32, view: ScintillaView) {
        guard parent.documentManager?.isAutocompletionEnabled == true else { return }

        // Trigger on alphanumeric and underscore
        let isWord = (ch >= 65 && ch <= 90) || (ch >= 97 && ch <= 122) || (ch >= 48 && ch <= 57) || ch == 95
        guard isWord else { return }

        let currentPos = view.message(UInt32(SCI_GETCURRENTPOS))
        guard currentPos > 0 else { return }

        let wordStart = view.message(UInt32(2266), wParam: UInt(currentPos), lParam: 1) // SCI_WORDSTARTPOSITION
        let lenEntered = currentPos - wordStart
        guard lenEntered >= 2 else { return }

        guard let fullText = view.string() else { return }
        let utf8 = fullText.utf8
        let startIdx = utf8.index(utf8.startIndex, offsetBy: wordStart, limitedBy: utf8.endIndex) ?? utf8.startIndex
        let endIdx = utf8.index(utf8.startIndex, offsetBy: currentPos, limitedBy: utf8.endIndex) ?? utf8.endIndex
        guard let prefix = String(utf8[startIdx..<endIdx]), !prefix.isEmpty else { return }

        let langKeywords = parent.language.keywords
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count >= 2 }

        let lowerPrefix = prefix.lowercased()
        var matches = Set<String>()
        for kw in langKeywords where kw.lowercased().hasPrefix(lowerPrefix) && kw.lowercased() != lowerPrefix {
            matches.insert(kw)
        }

        if matches.count < 10 {
            let bufferTokens = fullText.components(separatedBy: CharacterSet.alphanumerics.inverted)
            for token in bufferTokens {
                let lowerToken = token.lowercased()
                if token.count >= 3 && lowerToken.hasPrefix(lowerPrefix) && lowerToken != lowerPrefix {
                    matches.insert(token)
                    if matches.count >= 25 { break }
                }
            }
        }

        guard !matches.isEmpty else { return }
        let sortedMatches = matches.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        let matchString = sortedMatches.prefix(25).joined(separator: " ")

        matchString.withCString { cStr in
            view.message(UInt32(2106), wParam: UInt(32)) // SCI_AUTOCSETSEPARATOR
            view.message(UInt32(2115), wParam: 1) // SCI_AUTOCSETIGNORECASE
            view.message(UInt32(2118), wParam: 1) // SCI_AUTOCSETAUTOHIDE
            view.message(UInt32(2270), wParam: 1) // SCI_AUTOCSETDROPRESTOFWORD
            view.message(UInt32(2660), wParam: 0) // SCI_AUTOCSETORDER (SC_ORDER_PRESORTED)
            view.message(UInt32(2100), wParam: UInt(lenEntered), lParam: Int(bitPattern: cStr)) // SCI_AUTOCSHOW
        }
    }
}
