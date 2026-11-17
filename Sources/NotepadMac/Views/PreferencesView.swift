//
//  PreferencesView.swift
//  NotepadMac
//
//  Application preferences panel for themes, editor settings, and Lua scripting
//

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
            Text("Preferences")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(NSColor.labelColor))
            Spacer()
            Button("Done") {
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
            Text("Themes").tag(0)
            Text("Editor").tag(1)
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
                    themesTab
                } else if selectedTab == 1 {
                    editorTab
                } else {
                    luaScriptingTab
                }
            }
            .padding(20)
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

    // MARK: - Editor Tab

    private var editorTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Editor Appearance & Formatting")
                .font(.headline)
                .foregroundColor(Color(NSColor.labelColor))

            VStack(alignment: .leading, spacing: 6) {
                Text("Editor Font:")
                    .font(.subheadline)
                    .foregroundColor(Color(NSColor.secondaryLabelColor))

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
                        "Size: \(documentManager.fontSize) pt",
                        value: $documentManager.fontSize,
                        in: 9...36
                    )
                    .font(.system(size: 12))
                    .foregroundColor(Color(NSColor.labelColor))
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Toggle("Show Line Numbers", isOn: $documentManager.showLineNumbers)
                    .foregroundColor(Color(NSColor.labelColor))
                Toggle("Show Code Folding Margin", isOn: $documentManager.showFolding)
                    .foregroundColor(Color(NSColor.labelColor))
                Toggle("Word Wrap", isOn: $documentManager.isWordWrapEnabled)
                    .foregroundColor(Color(NSColor.labelColor))
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
        .onTapGesture {
            onSelect()
        }
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
