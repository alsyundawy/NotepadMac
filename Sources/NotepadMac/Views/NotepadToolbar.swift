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

public struct NotepadToolbar: View {
    @ObservedObject var documentManager: DocumentManager

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    private var hasDoc: Bool {
        documentManager.activeDocument != nil
    }

    public var body: some View {
        HStack(spacing: 4) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    fileGroup
                    toolbarDivider
                    clipboardGroup
                    toolbarDivider
                    historyGroup
                    toolbarDivider
                    searchGroup
                    toolbarDivider
                    zoomGroup
                    toolbarDivider
                    viewGroup
                    toolbarDivider
                    toolsGroup
                }
                .padding(.leading, 4)
            }

            Spacer(minLength: 8)

            toolsHubButton
            preferencesButton
            exitButton
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color(red: 0.13, green: 0.15, blue: 0.17))
        .foregroundColor(.white)
    }

    // MARK: - Group 1: File Operations (Notepad++ Standard)

    private var fileGroup: some View {
        Group {
            ToolbarButton(
                icon: "doc.badge.plus",
                title: loc("new_document"),
                shortcut: "⌘N",
                isEnabled: true
            ) {
                documentManager.newDocument()
            }
            ToolbarButton(
                icon: "folder",
                title: loc("open_file"),
                shortcut: "⌘O",
                isEnabled: true
            ) {
                documentManager.promptOpenDocument()
            }
            ToolbarButton(
                icon: "square.and.arrow.down",
                title: loc("save"),
                shortcut: "⌘S",
                isEnabled: hasDoc
            ) {
                documentManager.saveActiveDocument()
            }
            ToolbarButton(
                icon: "square.and.arrow.down.on.square.fill",
                title: loc("save_all"),
                shortcut: "⌥⌘S",
                isEnabled: hasDoc
            ) {
                documentManager.saveAllDocuments()
            }
            ToolbarButton(
                icon: "xmark.square",
                title: loc("close_tab"),
                shortcut: "⌘W",
                isEnabled: hasDoc
            ) {
                if let id = documentManager.activeDocumentID {
                    documentManager.closeDocument(id: id)
                }
            }
            ToolbarButton(
                icon: "xmark.square.fill",
                title: loc("close_all_tabs"),
                shortcut: "⌥⌘W",
                isEnabled: hasDoc
            ) {
                documentManager.closeAllDocuments()
            }
            ToolbarButton(
                icon: "printer",
                title: loc("print"),
                shortcut: "⌘P",
                isEnabled: hasDoc
            ) {
                NotificationCenter.default.post(name: .notepadPrint, object: nil)
            }
        }
    }

    // MARK: - Group 2: Edit & Clipboard (Notepad++ Order: Cut, Copy, Paste)

    private var clipboardGroup: some View {
        Group {
            ToolbarButton(
                icon: "scissors",
                title: loc("cut"),
                shortcut: "⌘X",
                isEnabled: hasDoc
            ) {
                NotificationCenter.default.post(name: .notepadCut, object: nil)
            }
            ToolbarButton(
                icon: "doc.on.doc",
                title: loc("copy_action"),
                shortcut: "⌘C",
                isEnabled: hasDoc
            ) {
                NotificationCenter.default.post(name: .notepadCopy, object: nil)
            }
            ToolbarButton(
                icon: "doc.on.clipboard",
                title: loc("paste"),
                shortcut: "⌘V",
                isEnabled: hasDoc
            ) {
                NotificationCenter.default.post(name: .notepadPaste, object: nil)
            }
        }
    }

    // MARK: - Group 3: History (Undo, Redo)

    private var historyGroup: some View {
        Group {
            ToolbarButton(
                icon: "arrow.uturn.backward",
                title: loc("undo"),
                shortcut: "⌘Z",
                isEnabled: hasDoc
            ) {
                NotificationCenter.default.post(name: .notepadUndo, object: nil)
            }
            ToolbarButton(
                icon: "arrow.uturn.forward",
                title: loc("redo"),
                shortcut: "⇧⌘Z",
                isEnabled: hasDoc
            ) {
                NotificationCenter.default.post(name: .notepadRedo, object: nil)
            }
        }
    }

    // MARK: - Group 4: Search Operations (Find, Replace)

    private var searchGroup: some View {
        Group {
            ToolbarButton(
                icon: "magnifyingglass",
                title: loc("find"),
                shortcut: "⌘F",
                isEnabled: hasDoc,
                isActive: documentManager.isFindReplaceDialogPresented && documentManager.findDialogTab == 0
            ) {
                documentManager.findDialogTab = 0
                documentManager.isFindReplaceDialogPresented = true
            }
            ToolbarButton(
                icon: "arrow.triangle.2.circlepath",
                title: loc("replace"),
                shortcut: "⌥⌘F",
                isEnabled: hasDoc,
                isActive: documentManager.isFindReplaceDialogPresented && documentManager.findDialogTab == 1
            ) {
                documentManager.findDialogTab = 1
                documentManager.isFindReplaceDialogPresented = true
            }
            ToolbarButton(
                icon: "bookmark.fill",
                title: loc("mark"),
                shortcut: "⇧⌘M",
                isEnabled: hasDoc,
                isActive: documentManager.isFindReplaceDialogPresented && documentManager.findDialogTab == 2
            ) {
                documentManager.findDialogTab = 2
                documentManager.isFindReplaceDialogPresented = true
            }
        }
    }

    // MARK: - Group 5: Zoom Controls (Notepad++ Order: Zoom In, Zoom Out)

    private var zoomGroup: some View {
        Group {
            ToolbarButton(
                icon: "plus.magnifyingglass",
                title: loc("zoom_in"),
                shortcut: "⌘+",
                isEnabled: hasDoc
            ) {
                documentManager.zoomIn()
            }
            ToolbarButton(
                icon: "minus.magnifyingglass",
                title: loc("zoom_out"),
                shortcut: "⌘-",
                isEnabled: hasDoc
            ) {
                documentManager.zoomOut()
            }
        }
    }

    // MARK: - Group 6: View & Formatting Toggles

    private var viewGroup: some View {
        Group {
            ToolbarButton(
                icon: "text.word.spacing",
                title: loc("word_wrap"),
                shortcut: "⌥Z",
                isEnabled: true,
                isActive: documentManager.isWordWrapEnabled
            ) {
                documentManager.isWordWrapEnabled.toggle()
            }
            ToolbarButton(
                icon: "paragraphsign",
                title: loc("white_space"),
                isEnabled: true,
                isActive: documentManager.showWhiteSpace
            ) {
                documentManager.showWhiteSpace.toggle()
            }
            ToolbarButton(
                icon: "ruler",
                title: loc("indent_guides"),
                isEnabled: true,
                isActive: documentManager.showIndentGuides
            ) {
                documentManager.showIndentGuides.toggle()
            }
        }
    }

    // MARK: - Group 7: Scripting & Tools

    private var toolsGroup: some View {
        Group {
            ToolbarButton(
                icon: "terminal",
                title: loc("lua_console"),
                shortcut: "⌥⌘L",
                isEnabled: true,
                isActive: documentManager.isLuaConsolePresented
            ) {
                documentManager.isLuaConsolePresented.toggle()
            }
        }
    }

    private var toolsHubButton: some View {
        ToolbarButton(
            icon: "wrench.and.screwdriver",
            title: loc("tools_hub"),
            shortcut: "⌃⌘T",
            isEnabled: true,
            isActive: documentManager.isToolsDialogPresented
        ) {
            documentManager.isToolsDialogPresented.toggle()
        }
    }

    private var preferencesButton: some View {
        ToolbarButton(
            icon: "gearshape",
            title: loc("preferences"),
            shortcut: "⌘,",
            isEnabled: true,
            isActive: documentManager.isPreferencesPresented
        ) {
            documentManager.isPreferencesPresented.toggle()
        }
    }

    private var exitButton: some View {
        ToolbarButton(
            icon: "power",
            title: loc("quit"),
            shortcut: "⌘Q",
            isEnabled: true,
            isActive: false
        ) {
            NSApp.terminate(nil)
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
    public var isEnabled: Bool = true
    public var isActive: Bool = false
    public let action: () -> Void

    @State private var isHovering: Bool = false

    private var buttonBgColor: Color {
        if !isEnabled {
            return Color.clear
        }
        if isActive {
            return Color.blue.opacity(0.25)
        }
        if isHovering {
            return Color.white.opacity(0.12)
        }
        return Color.clear
    }

    private var iconColor: Color {
        if !isEnabled {
            return Color.white.opacity(0.25)
        }
        if isActive {
            return Color(red: 0.35, green: 0.65, blue: 1.0)
        }
        return isHovering ? .white : Color(white: 0.85)
    }

    private var tooltipText: String {
        if let sc = shortcut, !sc.isEmpty {
            return "\(title) (\(sc))"
        }
        return title
    }

    public var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 26, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(buttonBgColor)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .disabled(!isEnabled)
        .onHover { hovering in
            if isEnabled {
                isHovering = hovering
            } else {
                isHovering = false
            }
        }
        .help(tooltipText)
    }
}
