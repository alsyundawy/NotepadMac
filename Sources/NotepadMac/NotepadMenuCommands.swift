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

struct AppMenuCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button(loc("about")) {
                NotificationCenter.default.post(
                    name: .notepadShowAbout,
                    object: nil
                )
            }

            Button(loc("check_updates")) {
                NotificationCenter.default.post(
                    name: .notepadShowCheckUpdate,
                    object: nil
                )
            }

            Divider()

            Button(loc("preferences") + "...") {
                NotificationCenter.default.post(
                    name: .notepadShowPreferences,
                    object: nil
                )
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}

struct FileMenuCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Document") {
                NotificationCenter.default.post(name: .notepadNewDocument, object: nil)
            }
            .keyboardShortcut("n", modifiers: .command)

            Button("Open File...") {
                NotificationCenter.default.post(name: .notepadOpenDocument, object: nil)
            }
            .keyboardShortcut("o", modifiers: .command)

            Divider()

            Button("Close Tab") {
                NotificationCenter.default.post(name: .notepadCloseTab, object: nil)
            }
            .keyboardShortcut("w", modifiers: .command)

            Button("Close All Tabs") {
                NotificationCenter.default.post(name: .notepadCloseAllTabs, object: nil)
            }
            .keyboardShortcut("w", modifiers: [.command, .option])

            Divider()

            Button("Save") {
                NotificationCenter.default.post(name: .notepadSaveDocument, object: nil)
            }
            .keyboardShortcut("s", modifiers: .command)

            Button("Save As...") {
                NotificationCenter.default.post(name: .notepadSaveAsDocument, object: nil)
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])

            Button("Save All") {
                NotificationCenter.default.post(name: .notepadSaveAllDocuments, object: nil)
            }
            .keyboardShortcut("s", modifiers: [.command, .option])

            Divider()

            Button("Page Setup...") {
                NotificationCenter.default.post(name: .notepadPageSetup, object: nil)
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])

            Button("Print...") {
                NotificationCenter.default.post(name: .notepadPrint, object: nil)
            }
            .keyboardShortcut("p", modifiers: .command)
        }
    }
}

struct EditMenuCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .undoRedo) {
            Button("Undo") {
                NotificationCenter.default.post(name: .notepadUndo, object: nil)
            }
            .keyboardShortcut("z", modifiers: .command)

            Button("Redo") {
                NotificationCenter.default.post(name: .notepadRedo, object: nil)
            }
            .keyboardShortcut("z", modifiers: [.command, .shift])
        }

        CommandGroup(replacing: .pasteboard) {
            Button("Cut") {
                NotificationCenter.default.post(name: .notepadCut, object: nil)
            }
            .keyboardShortcut("x", modifiers: .command)

            Button("Copy") {
                NotificationCenter.default.post(name: .notepadCopy, object: nil)
            }
            .keyboardShortcut("c", modifiers: .command)

            Button("Paste") {
                NotificationCenter.default.post(name: .notepadPaste, object: nil)
            }
            .keyboardShortcut("v", modifiers: .command)

            Button("Duplicate Line") {
                NotificationCenter.default.post(name: .notepadDuplicateLine, object: nil)
            }
            .keyboardShortcut("d", modifiers: .command)

            Button("Delete Line") {
                NotificationCenter.default.post(name: .notepadDeleteLine, object: nil)
            }
            .keyboardShortcut("k", modifiers: [.command, .shift])

            Button("Select All") {
                NotificationCenter.default.post(name: .notepadSelectAll, object: nil)
            }
            .keyboardShortcut("a", modifiers: .command)

            Button("Time/Date") {
                NotificationCenter.default.post(name: .notepadInsertDateTime, object: nil)
            }
            .keyboardShortcut(.init("5"), modifiers: [])
        }

        CommandMenu("Find") {
            Button(action: {
                NotificationCenter.default.post(name: .notepadShowFindDialog, object: nil)
            }) {
                Label("Find...", systemImage: "magnifyingglass")
            }
            .keyboardShortcut("f", modifiers: .command)

            Button(action: {
                NotificationCenter.default.post(name: .notepadShowReplaceDialog, object: nil)
            }) {
                Label("Replace...", systemImage: "arrow.triangle.2.circlepath")
            }
            .keyboardShortcut("f", modifiers: [.command, .option])

            Button(action: {
                NotificationCenter.default.post(name: .notepadToggleFind, object: nil)
            }) {
                Label("Toggle Find Bar", systemImage: "character.magnifyingglass")
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])

            Divider()

            Button("Find Next") {
                NotificationCenter.default.post(name: .notepadFindNext, object: nil)
            }
            .keyboardShortcut("g", modifiers: .command)

            Button("Find Previous") {
                NotificationCenter.default.post(name: .notepadFindPrevious, object: nil)
            }
            .keyboardShortcut("g", modifiers: [.command, .shift])

            Button("Use Selection for Find") {
                NotificationCenter.default.post(name: .notepadUseSelectionForFind, object: nil)
            }
            .keyboardShortcut("e", modifiers: .command)

            Button("Go to Line...") {
                NotificationCenter.default.post(name: .notepadPromptGoToLine, object: nil)
            }
            .keyboardShortcut("l", modifiers: .command)
        }
    }
}

struct FormatMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("Format") {
            Menu("Convert Case") {
                Button("UPPERCASE") {
                    NotificationCenter.default.post(name: .notepadMakeUpperCase, object: nil)
                }
                .keyboardShortcut("u", modifiers: [.command, .shift])

                Button("lowercase") {
                    NotificationCenter.default.post(name: .notepadMakeLowerCase, object: nil)
                }
                .keyboardShortcut("u", modifiers: [.option, .command])

                Button("Capitalize") {
                    NotificationCenter.default.post(name: .notepadCapitalize, object: nil)
                }

                Button("Invert Case") {
                    NotificationCenter.default.post(name: .notepadInvertCase, object: nil)
                }
            }

            Divider()

            Button(action: {
                NotificationCenter.default.post(name: .notepadToggleWordWrap, object: nil)
            }) {
                Label("Word Wrap", systemImage: "text.word.spacing")
            }
            .keyboardShortcut("z", modifiers: .option)

            Divider()

            Menu("Font Size") {
                Button(action: {
                    NotificationCenter.default.post(name: .notepadZoomIn, object: nil)
                }) {
                    Label("Bigger", systemImage: "plus.magnifyingglass")
                }
                .keyboardShortcut("+", modifiers: .command)

                Button(action: {
                    NotificationCenter.default.post(name: .notepadZoomOut, object: nil)
                }) {
                    Label("Smaller", systemImage: "minus.magnifyingglass")
                }
                .keyboardShortcut("-", modifiers: .command)

                Button(action: {
                    NotificationCenter.default.post(name: .notepadResetZoom, object: nil)
                }) {
                    Label("Default Size", systemImage: "equal.circle")
                }
                .keyboardShortcut("0", modifiers: .command)
            }

            Divider()

            lineEndingsMenu
            encodingMenu
        }
    }

    private var lineEndingsMenu: some View {
        Menu("Line Endings") {
            Button("Unix (LF)") {
                NotificationCenter.default.post(
                    name: .notepadSetLineEnding,
                    object: nil,
                    userInfo: ["ending": LineEnding.unixLF]
                )
            }
            Button("Windows (CRLF)") {
                NotificationCenter.default.post(
                    name: .notepadSetLineEnding,
                    object: nil,
                    userInfo: ["ending": LineEnding.windowsCRLF]
                )
            }
            Button("Classic Mac (CR)") {
                NotificationCenter.default.post(
                    name: .notepadSetLineEnding,
                    object: nil,
                    userInfo: ["ending": LineEnding.macCR]
                )
            }
        }
    }

    private var encodingMenu: some View {
        Menu("File Encoding") {
            Button("UTF-8") {
                NotificationCenter.default.post(
                    name: .notepadSetEncoding,
                    object: nil,
                    userInfo: ["encoding": String.Encoding.utf8]
                )
            }
            Button("UTF-16") {
                NotificationCenter.default.post(
                    name: .notepadSetEncoding,
                    object: nil,
                    userInfo: ["encoding": String.Encoding.utf16]
                )
            }
            Button("ASCII") {
                NotificationCenter.default.post(
                    name: .notepadSetEncoding,
                    object: nil,
                    userInfo: ["encoding": String.Encoding.ascii]
                )
            }
            Button("ISO-Latin-1") {
                NotificationCenter.default.post(
                    name: .notepadSetEncoding,
                    object: nil,
                    userInfo: ["encoding": String.Encoding.isoLatin1]
                )
            }
        }
    }
}

struct ViewMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("View") {
            Button("Toggle Line Numbers") {
                NotificationCenter.default.post(name: .notepadToggleLineNumbers, object: nil)
            }
            Button("Toggle Code Folding") {
                NotificationCenter.default.post(name: .notepadToggleFolding, object: nil)
            }
            Button("Toggle White Space & EOL") {
                NotificationCenter.default.post(name: .notepadToggleWhiteSpace, object: nil)
            }
            Button("Toggle Indentation Guides") {
                NotificationCenter.default.post(name: .notepadToggleIndentGuides, object: nil)
            }

            Divider()

            Button(action: {
                NotificationCenter.default.post(name: .notepadZoomIn, object: nil)
            }) {
                Label("Zoom In", systemImage: "plus.magnifyingglass")
            }
            .keyboardShortcut("+", modifiers: .command)

            Button(action: {
                NotificationCenter.default.post(name: .notepadZoomOut, object: nil)
            }) {
                Label("Zoom Out", systemImage: "minus.magnifyingglass")
            }
            .keyboardShortcut("-", modifiers: .command)

            Button(action: {
                NotificationCenter.default.post(name: .notepadResetZoom, object: nil)
            }) {
                Label("Reset Zoom", systemImage: "equal.circle")
            }
            .keyboardShortcut("0", modifiers: .command)
        }
    }
}

struct ExtraMenuCommands: Commands {
    var body: some Commands {
        CommandMenu("Language") {
            Button(LexerRegistry.shared.plainTextLanguage.displayName) {
                NotificationCenter.default.post(
                    name: .notepadSelectLanguage,
                    object: nil,
                    userInfo: ["language": LexerRegistry.shared.plainTextLanguage]
                )
            }

            Divider()

            ForEach(LexerRegistry.shared.alphabeticalGroups) { group in
                Menu(group.letter) {
                    ForEach(group.languages) { lang in
                        Button(lang.displayName) {
                            NotificationCenter.default.post(
                                name: .notepadSelectLanguage,
                                object: nil,
                                userInfo: ["language": lang]
                            )
                        }
                    }
                }
            }
        }

        CommandMenu("Theme") {
            ForEach(Theme.allThemes) { theme in
                Button(theme.name) {
                    NotificationCenter.default.post(
                        name: .notepadSelectTheme,
                        object: nil,
                        userInfo: ["theme": theme]
                    )
                }
            }
        }

        CommandMenu(loc("tools")) {
            Button(loc("tools_hub")) {
                NotificationCenter.default.post(
                    name: .notepadShowTools,
                    object: nil,
                    userInfo: ["tab": 0]
                )
            }
            .keyboardShortcut("t", modifiers: [.control, .command])

            Divider()

            Menu(loc("hash_tools")) {
                Button(loc("generate_hash") + " (SHA-256)...") {
                    NotificationCenter.default.post(
                        name: .notepadShowTools,
                        object: nil,
                        userInfo: ["tab": 0]
                    )
                }
                .keyboardShortcut("h", modifiers: [.control, .command])
            }

            Menu(loc("mime_tools")) {
                Button(loc("mime_tools") + " (Base64 / URL)...") {
                    NotificationCenter.default.post(
                        name: .notepadShowTools,
                        object: nil,
                        userInfo: ["tab": 1]
                    )
                }
                .keyboardShortcut("m", modifiers: [.control, .command])
            }

            Menu(loc("converter")) {
                Button(loc("converter") + " (HEX / Numbers)...") {
                    NotificationCenter.default.post(
                        name: .notepadShowTools,
                        object: nil,
                        userInfo: ["tab": 2]
                    )
                }
                .keyboardShortcut("c", modifiers: [.control, .command])
            }

            Menu(loc("encryption")) {
                Button(loc("encryption") + " (AES-256)...") {
                    NotificationCenter.default.post(
                        name: .notepadShowTools,
                        object: nil,
                        userInfo: ["tab": 3]
                    )
                }
                .keyboardShortcut("e", modifiers: [.control, .command])
            }

            Menu(loc("developer_tools")) {
                Button(loc("developer_tools") + " (JSON / XML / JWT)...") {
                    NotificationCenter.default.post(
                        name: .notepadShowTools,
                        object: nil,
                        userInfo: ["tab": 4]
                    )
                }
                .keyboardShortcut("d", modifiers: [.control, .command])
            }

            Divider()

            Button(loc("lua_console")) {
                NotificationCenter.default.post(name: .notepadToggleLuaConsole, object: nil)
            }
            .keyboardShortcut("l", modifiers: [.command, .option])
        }

        CommandGroup(replacing: .help) {
            Button("NotepadMac Help") {
                if let url = URL(string: "https://github.com/alsyundawy/NotepadMac") {
                    NSWorkspace.shared.open(url)
                }
            }
            Button(loc("about")) {
                NotificationCenter.default.post(name: .notepadShowAbout, object: nil)
            }
            Button(loc("check_updates")) {
                NotificationCenter.default.post(name: .notepadShowCheckUpdate, object: nil)
            }
            Divider()
            Button(loc("keyboard_shortcuts")) {
                NotificationCenter.default.post(name: .notepadShowPreferences, object: nil)
            }
        }
    }
}
