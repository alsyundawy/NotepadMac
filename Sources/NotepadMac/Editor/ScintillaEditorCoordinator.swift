//
//  ScintillaEditorCoordinator.swift
//  NotepadMac
//
//  Notification coordinator bridging native Scintilla Cocoa events to SwiftUI
//

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
            let printOp = NSPrintOperation(view: view, printInfo: .shared)
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
}
