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

public struct TabColorItem: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let hex: String

    public init(id: String, name: String, hex: String) {
        self.id = id
        self.name = name
        self.hex = hex
    }
}

public struct RenameTabSheet: View {
    @ObservedObject public var documentManager: DocumentManager
    @State private var customColor: Color = .blue

    public static let presetColors: [TabColorItem] = [
        TabColorItem(id: "red", name: "Red", hex: "#ff5f57"),
        TabColorItem(id: "coral", name: "Coral", hex: "#fe942e"),
        TabColorItem(id: "yellow", name: "Yellow", hex: "#fdbc40"),
        TabColorItem(id: "green", name: "Green", hex: "#28c840"),
        TabColorItem(id: "teal", name: "Teal", hex: "#20c997"),
        TabColorItem(id: "blue", name: "Blue", hex: "#528bff"),
        TabColorItem(id: "indigo", name: "Indigo", hex: "#6366f1"),
        TabColorItem(id: "purple", name: "Purple", hex: "#b362ff"),
        TabColorItem(id: "pink", name: "Pink", hex: "#ec4899"),
        TabColorItem(id: "gray", name: "Gray", hex: "#808080")
    ]

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()

            VStack(alignment: .leading, spacing: 14) {
                if let doc = documentManager.documentToRename, doc.fileURL != nil {
                    diskFileInfoBanner(doc: doc)
                }

                inputSection
                colorPickerSection
            }
            .padding(16)

            Spacer(minLength: 0)
            Divider()
            footerBar
        }
        .frame(minWidth: 480, minHeight: 280)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            if let hex = documentManager.renameTabColorHex {
                customColor = Color(hex: hex)
            }
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "pencil.and.outline")
                .foregroundColor(.blue)
                .font(.system(size: 15, weight: .semibold))

            Text(loc("rename_tab_title"))
                .font(.system(size: 13, weight: .bold))

            Spacer()

            ModalCloseButton {
                documentManager.isRenameTabPresented = false
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Disk File Info Banner

    private func diskFileInfoBanner(doc: EditorDocument) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "externaldrive.badge.timemachine")
                .foregroundColor(.orange)
                .font(.system(size: 18))

            VStack(alignment: .leading, spacing: 2) {
                Text(loc("file_rename_warning"))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(NSColor.labelColor))

                if let url = doc.fileURL {
                    Text(url.path)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            Spacer()
        }
        .padding(10)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(loc("document_name"))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(NSColor.labelColor))

            TextField(loc("document_name"), text: $documentManager.renameTabInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 13))

            if let errorMsg = documentManager.renameTabError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 11))
                    Text(errorMsg)
                        .foregroundColor(.red)
                        .font(.system(size: 11))
                }
            }
        }
    }

    // MARK: - Tab Color Palette Section

    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc("tab_color"))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(NSColor.labelColor))

            HStack(spacing: 8) {
                // No Color button
                Button(action: {
                    documentManager.renameTabColorHex = nil
                }) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 22, height: 22)

                        Image(systemName: "slash.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: documentManager.renameTabColorHex == nil ? 2 : 0)
                            .padding(-3)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .help(loc("no_color"))

                // Preset color swatches
                ForEach(RenameTabSheet.presetColors) { item in
                    let isSelected = documentManager.renameTabColorHex?.uppercased() == item.hex.uppercased()

                    Button(action: {
                        documentManager.renameTabColorHex = item.hex
                        customColor = Color(hex: item.hex)
                    }) {
                        Circle()
                            .fill(Color(hex: item.hex))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: isSelected ? 2 : 0)
                                    .padding(-3)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help(item.name)
                }

                // Native Custom Color Picker
                ColorPicker("", selection: Binding(
                    get: { customColor },
                    set: { newColor in
                        customColor = newColor
                        documentManager.renameTabColorHex = newColor.toHex()
                    }
                ), supportsOpacity: false)
                .labelsHidden()
                .frame(width: 24, height: 24)
                .help(loc("custom_color"))
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Footer Bar

    private var footerBar: some View {
        HStack(spacing: 12) {
            Button(loc("cancel")) {
                documentManager.isRenameTabPresented = false
            }
            .buttonStyle(SecondaryButtonStyle())
            .font(.system(size: 12))

            Spacer()

            Button(loc("apply")) {
                documentManager.applyRenameDocument()
            }
            .buttonStyle(ProminentButtonStyle())
            .font(.system(size: 12, weight: .semibold))
            .keyboardShortcut(.defaultAction)
            .disabled(documentManager.renameTabInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
}
