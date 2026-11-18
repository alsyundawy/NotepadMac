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

public struct PreferencesView: View {
    @ObservedObject var documentManager: DocumentManager
    @State private var selectedTab: Int = 0

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()
            tabSelector
            Divider()
            tabContent
        }
        .frame(width: 540, height: 430)
        .background(Color(NSColor.windowBackgroundColor))
        .foregroundColor(Color(NSColor.labelColor))
    }

    // MARK: - Subviews

    private var headerBar: some View {
        HStack {
            Text(loc("preferences"))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(NSColor.labelColor))
            Spacer()
            Button(loc("done")) {
                documentManager.isPreferencesPresented = false
            }
            .buttonStyle(ProminentButtonStyle())
            .font(.system(size: 11))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var tabSelector: some View {
        Picker("", selection: $selectedTab) {
            Text(loc("general")).tag(0)
            Text(loc("themes")).tag(1)
            Text("Lua Scripting").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private var tabContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if selectedTab == 0 {
                    generalTab
                } else if selectedTab == 1 {
                    themesTab
                } else {
                    luaScriptingTab
                }
            }
            .padding(20)
        }
    }

    // MARK: - General Tab (Enriched Preferences)

    private var generalTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section 1: Application Language
            VStack(alignment: .leading, spacing: 8) {
                Text(loc("app_language"))
                    .font(.headline)
                    .foregroundColor(Color(NSColor.labelColor))

                HStack(spacing: 12) {
                    Picker("", selection: Binding(
                        get: { LocalizationManager.shared.currentLanguage },
                        set: { newLang in
                            LocalizationManager.shared.currentLanguage = newLang
                            documentManager.objectWillChange.send()
                        }
                    )) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text("\(lang.flag) \(lang.displayName)").tag(lang)
                        }
                    }
                    .frame(width: 220)

                    Text(loc("language_restart_note"))
                        .font(.caption)
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                }
            }

            Divider()

            // Section 2: Editor Font & Sizing
            VStack(alignment: .leading, spacing: 8) {
                Text(loc("editor_font"))
                    .font(.headline)
                    .foregroundColor(Color(NSColor.labelColor))

                HStack {
                    Picker("", selection: $documentManager.fontName) {
                        Text("Menlo").tag("Menlo")
                        Text("SF Mono").tag("SF Mono")
                        Text("Monaco").tag("Monaco")
                        Text("Courier New").tag("Courier New")
                    }
                    .frame(width: 180)

                    Spacer()

                    Stepper(
                        "\(loc("font_size")): \(documentManager.fontSize) pt",
                        value: $documentManager.fontSize,
                        in: 9...36
                    )
                    .font(.system(size: 12))
                    .foregroundColor(Color(NSColor.labelColor))
                }
            }

            Divider()

            // Section 3: Indentation
            VStack(alignment: .leading, spacing: 8) {
                Text("Indentation & Spacing")
                    .font(.headline)
                    .foregroundColor(Color(NSColor.labelColor))

                HStack {
                    Text(loc("tab_size") + ":")
                        .font(.subheadline)
                        .foregroundColor(Color(NSColor.secondaryLabelColor))

                    Picker("", selection: $documentManager.tabIndentSpaces) {
                        Text("2 spaces").tag(2)
                        Text("4 spaces").tag(4)
                        Text("8 spaces").tag(8)
                    }
                    .frame(width: 140)

                    Spacer()

                    Toggle(loc("insert_spaces"), isOn: $documentManager.useSpacesForTab)
                        .foregroundColor(Color(NSColor.labelColor))
                }
            }

            Divider()

            // Section 4: Editor Appearance & Margins
            VStack(alignment: .leading, spacing: 10) {
                Text(loc("appearance_options"))
                    .font(.headline)
                    .foregroundColor(Color(NSColor.labelColor))

                Toggle(loc("line_numbers"), isOn: $documentManager.showLineNumbers)
                    .foregroundColor(Color(NSColor.labelColor))
                Toggle(loc("code_folding"), isOn: $documentManager.showFolding)
                    .foregroundColor(Color(NSColor.labelColor))
                Toggle(loc("word_wrap"), isOn: $documentManager.isWordWrapEnabled)
                    .foregroundColor(Color(NSColor.labelColor))
                Toggle(loc("white_space"), isOn: $documentManager.showWhiteSpace)
                    .foregroundColor(Color(NSColor.labelColor))
                Toggle(loc("indent_guides"), isOn: $documentManager.showIndentGuides)
                    .foregroundColor(Color(NSColor.labelColor))
                Toggle(loc("autocompletion"), isOn: $documentManager.isAutocompletionEnabled)
                    .foregroundColor(Color(NSColor.labelColor))
                    .help(loc("autocompletion_desc"))
            }

            Divider()

            // Section 5: Updates
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("NotepadMac v1.0.0 (Build 2026.11)")
                        .font(.system(size: 12, weight: .semibold))
                    Text("GPLv3 Open Source • Designed for macOS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(loc("check_updates")) {
                    documentManager.showCheckForUpdates()
                }
                .font(.system(size: 12))
            }
        }
    }

    // MARK: - Themes Tab

    private var themesTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Select Editor Theme")
                .font(.headline)
                .foregroundColor(Color(NSColor.labelColor))

            VStack(spacing: 8) {
                ForEach(Theme.allThemes) { theme in
                    ThemeRowView(
                        theme: theme,
                        isSelected: documentManager.activeTheme.id == theme.id,
                        onSelect: {
                            documentManager.activeTheme = theme
                        }
                    )
                }
            }
        }
    }

    // MARK: - Lua Scripting Tab

    private var luaScriptingTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lua Automation API (Lua 5.5.1)")
                .font(.headline)
                .foregroundColor(Color(NSColor.labelColor))

            Text("Write scripts in Lua Console (⌥⌘L) using 'editor' table:")
                .font(.subheadline)
                .foregroundColor(Color(NSColor.secondaryLabelColor))

            VStack(alignment: .leading, spacing: 6) {
                ApiDocRow(
                    signature: "editor.getText() -> string",
                    description: "Returns the full text content of active document."
                )
                ApiDocRow(
                    signature: "editor.setText(string)",
                    description: "Replaces document text with the given string."
                )
                ApiDocRow(
                    signature: "editor.getSelection() -> string",
                    description: "Returns currently selected text."
                )
                ApiDocRow(
                    signature: "editor.replaceSelection(string)",
                    description: "Replaces current selection with the given string."
                )
                ApiDocRow(
                    signature: "editor.getLineCount() -> number",
                    description: "Returns total line count."
                )
                ApiDocRow(
                    signature: "editor.getCurrentLine() -> number",
                    description: "Returns 1-indexed line where cursor is located."
                )
                ApiDocRow(
                    signature: "editor.insertText(position, string)",
                    description: "Inserts text at specified character offset."
                )
                ApiDocRow(
                    signature: "editor.clear()",
                    description: "Clears the document buffer."
                )
                ApiDocRow(
                    signature: "editor.zoomIn() / editor.zoomOut()",
                    description: "Adjusts font zoom level."
                )
                ApiDocRow(
                    signature: "print(...)",
                    description: "Prints output to the Lua Console log."
                )
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
            .cornerRadius(6)
        }
    }
}

public struct ThemeRowView: View {
    public let theme: Theme
    public let isSelected: Bool
    public let onSelect: () -> Void

    public var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(theme.name)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(Color(NSColor.labelColor))

                Spacer()

                HStack(spacing: 4) {
                    Circle().fill(Color(hex: theme.backgroundHex)).frame(width: 14, height: 14)
                    Circle().fill(Color(hex: theme.foregroundHex)).frame(width: 14, height: 14)
                    Circle().fill(Color(hex: theme.keywordHex)).frame(width: 14, height: 14)
                    Circle().fill(Color(hex: theme.stringHex)).frame(width: 14, height: 14)
                }

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color.accentColor)
                        .font(.system(size: 12, weight: .bold))
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        isSelected
                            ? Color.accentColor.opacity(0.18)
                            : Color(NSColor.controlBackgroundColor).opacity(0.4)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

public struct ApiDocRow: View {
    public let signature: String
    public let description: String

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(signature)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color.accentColor)
            Text(description)
                .font(.system(size: 10))
                .foregroundColor(Color(NSColor.secondaryLabelColor))
        }
    }
}
