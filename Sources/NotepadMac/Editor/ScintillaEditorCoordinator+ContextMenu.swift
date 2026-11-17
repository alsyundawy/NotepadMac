//
//  ScintillaEditorCoordinator+ContextMenu.swift
//  NotepadMac
//
//  Native macOS right-click contextual menu for editor canvas
//

import AppKit
import Foundation
import ScintillaCocoa

extension ScintillaEditorCoordinator {
    func buildEditorContextMenu() -> NSMenu {
        let menu = NSMenu(title: "Editor Context Menu")

        // Undo / Redo
        addMenuItem(to: menu, title: "Undo", action: #selector(contextUndo), key: "z")
        addMenuItem(to: menu, title: "Redo", action: #selector(contextRedo), key: "Z")
        menu.addItem(NSMenuItem.separator())

        // Cut / Copy / Paste / Select All
        addMenuItem(to: menu, title: "Cut", action: #selector(contextCut), key: "x")
        addMenuItem(to: menu, title: "Copy", action: #selector(contextCopy), key: "c")
        addMenuItem(to: menu, title: "Paste", action: #selector(contextPaste), key: "v")
        addMenuItem(to: menu, title: "Duplicate Line", action: #selector(contextDuplicateLine), key: "d")
        addMenuItem(to: menu, title: "Delete Line", action: #selector(contextDeleteLine), key: "")
        addMenuItem(to: menu, title: "Select All", action: #selector(contextSelectAll), key: "a")
        menu.addItem(NSMenuItem.separator())

        // Find Submenu
        let findSubmenu = NSMenu(title: "Find")
        addMenuItem(to: findSubmenu, title: "Find...", action: #selector(contextFind), key: "f", icon: "magnifyingglass")
        addMenuItem(
            to: findSubmenu,
            title: "Replace...",
            action: #selector(contextReplace),
            key: "",
            icon: "arrow.triangle.2.circlepath"
        )
        addMenuItem(to: findSubmenu, title: "Find Next", action: #selector(contextFindNext), key: "g", icon: "chevron.down")
        addMenuItem(to: findSubmenu, title: "Find Previous", action: #selector(contextFindPrev), key: "G", icon: "chevron.up")
        addMenuItem(
            to: findSubmenu,
            title: "Use Selection for Find",
            action: #selector(contextUseSelectionForFind),
            key: "e",
            icon: "character.cursor.ibeam"
        )
        let findParent = NSMenuItem(title: "Find", action: nil, keyEquivalent: "")
        findParent.image = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "Find")
        findParent.submenu = findSubmenu
        menu.addItem(findParent)

        // Convert Case Submenu
        let caseSubmenu = NSMenu(title: "Convert Case")
        addMenuItem(to: caseSubmenu, title: "UPPERCASE", action: #selector(contextUpper), key: "")
        addMenuItem(to: caseSubmenu, title: "lowercase", action: #selector(contextLower), key: "")
        addMenuItem(to: caseSubmenu, title: "Capitalize", action: #selector(contextCapitalize), key: "")
        addMenuItem(to: caseSubmenu, title: "Invert Case", action: #selector(contextInvertCase), key: "")
        let caseParent = NSMenuItem(title: "Convert Case", action: nil, keyEquivalent: "")
        caseParent.image = NSImage(systemSymbolName: "textformat", accessibilityDescription: "Convert Case")
        caseParent.submenu = caseSubmenu
        menu.addItem(caseParent)
        menu.addItem(NSMenuItem.separator())

        // Navigation & Insert
        addMenuItem(to: menu, title: "Go to Line...", action: #selector(contextGoToLine), key: "l", icon: "arrow.right.to.line")
        addMenuItem(to: menu, title: "Insert Date / Time", action: #selector(contextInsertDateTime), key: "", icon: "calendar.badge.clock")
        menu.addItem(NSMenuItem.separator())

        // Quick Editor Toggles
        addMenuItem(to: menu, title: "Toggle Word Wrap", action: #selector(contextToggleWrap), key: "", icon: "text.word.spacing")
        addMenuItem(to: menu, title: "Toggle Line Numbers", action: #selector(contextToggleLineNumbers), key: "", icon: "list.number")
        addMenuItem(to: menu, title: "Toggle Code Folding", action: #selector(contextToggleFolding), key: "", icon: "sidebar.squares.left")

        // Zoom Submenu
        let zoomSubmenu = NSMenu(title: "Zoom")
        addMenuItem(to: zoomSubmenu, title: "Zoom In", action: #selector(contextZoomIn), key: "+", icon: "plus.magnifyingglass")
        addMenuItem(to: zoomSubmenu, title: "Zoom Out", action: #selector(contextZoomOut), key: "-", icon: "minus.magnifyingglass")
        addMenuItem(to: zoomSubmenu, title: "Reset Zoom", action: #selector(contextResetZoom), key: "0", icon: "equal.circle")
        let zoomParent = NSMenuItem(title: "Zoom", action: nil, keyEquivalent: "")
        zoomParent.image = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "Zoom")
        zoomParent.submenu = zoomSubmenu
        menu.addItem(zoomParent)
        menu.addItem(NSMenuItem.separator())

        // Lua Console
        let luaItem = NSMenuItem(title: "Lua Scripting Console...", action: #selector(contextLuaConsole), keyEquivalent: "l")
        luaItem.keyEquivalentModifierMask = [.command, .option]
        luaItem.target = self
        menu.addItem(luaItem)

        return menu
    }

    private func addMenuItem(
        to menu: NSMenu,
        title: String,
        action: Selector,
        key: String,
        icon: String? = nil
    ) {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        if let icon = icon {
            item.image = NSImage(systemSymbolName: icon, accessibilityDescription: title)
        }
        menu.addItem(item)
    }

    // MARK: - Context Menu Selectors

    @objc func contextUndo() { scintillaView?.message(UInt32(2176)) }
    @objc func contextRedo() { scintillaView?.message(UInt32(2011)) }
    @objc func contextCut() { scintillaView?.message(UInt32(2177)) }
    @objc func contextCopy() { scintillaView?.message(UInt32(2178)) }
    @objc func contextPaste() { scintillaView?.message(UInt32(2179)) }
    @objc func contextDuplicateLine() { scintillaView?.message(UInt32(2404)) }
    @objc func contextDeleteLine() { scintillaView?.message(UInt32(2338)) }
    @objc func contextSelectAll() { scintillaView?.message(UInt32(2013)) }

    @objc func contextFind() {
        NotificationCenter.default.post(name: .notepadShowFindDialog, object: nil)
    }
    @objc func contextReplace() {
        NotificationCenter.default.post(name: .notepadShowReplaceDialog, object: nil)
    }
    @objc func contextFindNext() {
        NotificationCenter.default.post(name: .notepadFindNext, object: nil)
    }
    @objc func contextFindPrev() {
        NotificationCenter.default.post(name: .notepadFindPrevious, object: nil)
    }
    @objc func contextUseSelectionForFind() {
        NotificationCenter.default.post(name: .notepadUseSelectionForFind, object: nil)
    }

    @objc func contextUpper() {
        NotificationCenter.default.post(name: .notepadMakeUpperCase, object: nil)
    }
    @objc func contextLower() {
        NotificationCenter.default.post(name: .notepadMakeLowerCase, object: nil)
    }
    @objc func contextCapitalize() {
        NotificationCenter.default.post(name: .notepadCapitalize, object: nil)
    }
    @objc func contextInvertCase() {
        NotificationCenter.default.post(name: .notepadInvertCase, object: nil)
    }

    @objc func contextGoToLine() {
        NotificationCenter.default.post(name: .notepadPromptGoToLine, object: nil)
    }
    @objc func contextInsertDateTime() {
        NotificationCenter.default.post(name: .notepadInsertDateTime, object: nil)
    }

    @objc func contextToggleWrap() {
        NotificationCenter.default.post(name: .notepadToggleWordWrap, object: nil)
    }
    @objc func contextToggleLineNumbers() {
        NotificationCenter.default.post(name: .notepadToggleLineNumbers, object: nil)
    }
    @objc func contextToggleFolding() {
        NotificationCenter.default.post(name: .notepadToggleFolding, object: nil)
    }

    @objc func contextZoomIn() {
        NotificationCenter.default.post(name: .notepadZoomIn, object: nil)
    }
    @objc func contextZoomOut() {
        NotificationCenter.default.post(name: .notepadZoomOut, object: nil)
    }
    @objc func contextResetZoom() {
        NotificationCenter.default.post(name: .notepadResetZoom, object: nil)
    }

    @objc func contextLuaConsole() {
        NotificationCenter.default.post(name: .notepadToggleLuaConsole, object: nil)
    }
}
