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

import SwiftUI
import AppKit

extension Notification.Name {
    public static let notepadNewDocument = Notification.Name("notepadNewDocument")
    public static let notepadOpenDocument = Notification.Name("notepadOpenDocument")
    public static let notepadSaveDocument = Notification.Name("notepadSaveDocument")
    public static let notepadSaveAsDocument = Notification.Name("notepadSaveAsDocument")
    public static let notepadSaveAllDocuments = Notification.Name("notepadSaveAllDocuments")
    public static let notepadCloseTab = Notification.Name("notepadCloseTab")
    public static let notepadCloseAllTabs = Notification.Name("notepadCloseAllTabs")
    public static let notepadPageSetup = Notification.Name("notepadPageSetup")
    public static let notepadPrint = Notification.Name("notepadPrint")

    public static let notepadUndo = Notification.Name("notepadUndo")
    public static let notepadRedo = Notification.Name("notepadRedo")
    public static let notepadCut = Notification.Name("notepadCut")
    public static let notepadCopy = Notification.Name("notepadCopy")
    public static let notepadPaste = Notification.Name("notepadPaste")
    public static let notepadSelectAll = Notification.Name("notepadSelectAll")
    public static let notepadIndent = Notification.Name("notepadIndent")
    public static let notepadOutdent = Notification.Name("notepadOutdent")
    public static let notepadDuplicateLine = Notification.Name("notepadDuplicateLine")
    public static let notepadDeleteLine = Notification.Name("notepadDeleteLine")
    public static let notepadInsertDateTime = Notification.Name("notepadInsertDateTime")
    public static let notepadMakeUpperCase = Notification.Name("notepadMakeUpperCase")
    public static let notepadMakeLowerCase = Notification.Name("notepadMakeLowerCase")
    public static let notepadCapitalize = Notification.Name("notepadCapitalize")
    public static let notepadInvertCase = Notification.Name("notepadInvertCase")
    public static let notepadGoToLine = Notification.Name("notepadGoToLine")
    public static let notepadPromptGoToLine = Notification.Name("notepadPromptGoToLine")

    public static let notepadToggleFind = Notification.Name("notepadToggleFind")
    public static let notepadShowFindDialog = Notification.Name("notepadShowFindDialog")
    public static let notepadShowReplaceDialog = Notification.Name("notepadShowReplaceDialog")
    public static let notepadShowMarkDialog = Notification.Name("notepadShowMarkDialog")
    public static let notepadFindNext = Notification.Name("notepadFindNext")
    public static let notepadFindPrevious = Notification.Name("notepadFindPrevious")
    public static let notepadReplaceNext = Notification.Name("notepadReplaceNext")
    public static let notepadReplaceAll = Notification.Name("notepadReplaceAll")
    public static let notepadCountOccurrences = Notification.Name("notepadCountOccurrences")
    public static let notepadMarkAll = Notification.Name("notepadMarkAll")
    public static let notepadClearMarks = Notification.Name("notepadClearMarks")
    public static let notepadCopyMarkedText = Notification.Name("notepadCopyMarkedText")
    public static let notepadUseSelectionForFind = Notification.Name("notepadUseSelectionForFind")
    public static let notepadSearchStatusUpdate = Notification.Name("notepadSearchStatusUpdate")

    public static let notepadToggleWordWrap = Notification.Name("notepadToggleWordWrap")
    public static let notepadToggleLineNumbers = Notification.Name("notepadToggleLineNumbers")
    public static let notepadToggleFolding = Notification.Name("notepadToggleFolding")
    public static let notepadToggleWhiteSpace = Notification.Name("notepadToggleWhiteSpace")
    public static let notepadToggleIndentGuides = Notification.Name("notepadToggleIndentGuides")
    public static let notepadZoomIn = Notification.Name("notepadZoomIn")
    public static let notepadZoomOut = Notification.Name("notepadZoomOut")
    public static let notepadResetZoom = Notification.Name("notepadResetZoom")

    public static let notepadSelectLanguage = Notification.Name("notepadSelectLanguage")
    public static let notepadSelectTheme = Notification.Name("notepadSelectTheme")
    public static let notepadSetLineEnding = Notification.Name("notepadSetLineEnding")
    public static let notepadSetEncoding = Notification.Name("notepadSetEncoding")
    public static let notepadToggleLuaConsole = Notification.Name("notepadToggleLuaConsole")
    public static let notepadShowPreferences = Notification.Name("notepadShowPreferences")
    public static let notepadShowAbout = Notification.Name("notepadShowAbout")
    public static let notepadShowTools = Notification.Name("notepadShowTools")
    public static let notepadShowCheckUpdate = Notification.Name("notepadShowCheckUpdate")
    public static let notepadQuitApp = Notification.Name("notepadQuitApp")
}

@main
struct NotepadMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainEditorView()
        }
        .windowStyle(DefaultWindowStyle())
        .commands {
            AppMenuCommands()
            FileMenuCommands()
            EditMenuCommands()
            FormatMenuCommands()
            ViewMenuCommands()
            ExtraMenuCommands()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    weak var documentManager: DocumentManager?

    var activeManager: DocumentManager? {
        documentManager ?? DocumentManager.mainInstance
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWindowDidBecomeKey(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )
    }

    @objc private func handleWindowDidBecomeKey(_ notif: Notification) {
        if let window = notif.object as? NSWindow, window.delegate == nil {
            window.delegate = self
        }
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard let manager = activeManager else { return true }
        for doc in manager.documents where doc.isModified {
            manager.activeDocumentID = doc.id
            if !manager.confirmCloseDocument(doc, window: sender) {
                return false
            }
        }
        return true
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let manager = activeManager else { return .terminateNow }
        for doc in manager.documents where doc.isModified {
            manager.activeDocumentID = doc.id
            if !manager.confirmCloseDocument(doc) {
                return .terminateCancel
            }
        }
        return .terminateNow
    }

    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        true
    }
}
