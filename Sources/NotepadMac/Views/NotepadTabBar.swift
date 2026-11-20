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

public struct NotepadTabBar: View {
    @ObservedObject var documentManager: DocumentManager

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    private var theme: Theme {
        documentManager.activeTheme
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Base bottom divider across the entire tab strip
            Rectangle()
                .fill(theme.borderSwiftUIColor)
                .frame(height: 1)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 3) {
                    ForEach(Array(documentManager.documents.enumerated()), id: \.element.id) { _, doc in
                        let isActive = (doc.id == documentManager.activeDocumentID)

                        TabItemView(
                            document: doc,
                            isActive: isActive,
                            theme: theme,
                            onSelect: {
                                documentManager.activeDocumentID = doc.id
                            },
                            onRename: {
                                documentManager.promptRenameDocument(doc)
                            },
                            onClose: {
                                documentManager.closeDocument(id: doc.id)
                            },
                            onCloseOthers: {
                                documentManager.closeOtherDocuments(except: doc.id)
                            },
                            onCloseToTheRight: {
                                documentManager.closeTabsToTheRight(of: doc.id)
                            }
                        )
                    }

                    addTabButton
                        .padding(.leading, 6)

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
            }
        }
        .frame(height: 35)
        .background(theme.tabBarBgSwiftUIColor)
    }

    private var addTabButton: some View {
        Button(action: {
            documentManager.newDocument()
        }) {
            Image(systemName: "plus")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(theme.isDark ? Color(white: 0.7) : Color(hex: "#57606a"))
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(theme.isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(theme.borderSwiftUIColor.opacity(0.3), lineWidth: 0.8)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .help("\(loc("new_tab")) (⌘N)")
    }
}

// MARK: - Tab Item View

public struct TabItemView: View {
    @ObservedObject var document: EditorDocument
    public let isActive: Bool
    public let theme: Theme
    public let onSelect: () -> Void
    public let onRename: () -> Void
    public let onClose: () -> Void
    public let onCloseOthers: () -> Void
    public let onCloseToTheRight: () -> Void

    @State private var isHovering: Bool = false
    @State private var isCloseHovering: Bool = false

    private var accentColor: Color {
        if let hex = document.tagColorHex {
            return Color(hex: hex)
        }
        return theme.isDark ? Color(hex: "#58a6ff") : Color(hex: "#0969da")
    }

    private var tabBgColor: Color {
        if let tagHex = document.tagColorHex {
            let baseTag = Color(hex: tagHex)
            if isActive {
                return theme.isDark ? baseTag.opacity(0.24) : baseTag.opacity(0.16)
            } else if isHovering {
                return theme.isDark ? baseTag.opacity(0.18) : baseTag.opacity(0.11)
            } else {
                return theme.isDark ? baseTag.opacity(0.12) : baseTag.opacity(0.07)
            }
        }
        if isActive {
            return theme.activeTabBgSwiftUIColor
        }
        if isHovering {
            return theme.isDark ? Color.white.opacity(0.07) : Color.black.opacity(0.04)
        }
        return Color.clear
    }

    private var titleColor: Color {
        if isActive {
            return theme.foregroundSwiftUIColor
        }
        if isHovering {
            return theme.isDark ? Color.white : Color.black
        }
        return theme.isDark ? Color(white: 0.65) : Color(hex: "#57606a")
    }

    public var body: some View {
        HStack(spacing: 6) {
            // Main selectable tab area
            Button(action: onSelect) {
                HStack(spacing: 7) {
                    // File type icon with distinct semantic color
                    Image(systemName: fileIconInfo.name)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(isActive ? fileIconInfo.color : fileIconInfo.color.opacity(0.7))

                    // Color tag badge if customized
                    if let tagHex = document.tagColorHex {
                        Circle()
                            .fill(Color(hex: tagHex))
                            .frame(width: 6, height: 6)
                    }

                    // Document title
                    Text(document.title)
                        .font(.system(size: 11.5, weight: isActive ? .semibold : .regular))
                        .foregroundColor(titleColor)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: 160, alignment: .leading)

                    // Saved / Unsaved state color indicator
                    if document.isModified {
                        Circle()
                            .fill(Color(hex: "#ff5f57")) // Warm glowing amber-red for unsaved
                            .frame(width: 7, height: 7)
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "#ff5f57").opacity(0.5), lineWidth: 1.5)
                            )
                            .help(loc("unsaved_changes"))
                    } else {
                        Circle()
                            .fill(Color(hex: "#28c840").opacity(0.75)) // Calm green for saved
                            .frame(width: 5.5, height: 5.5)
                            .help(loc("saved"))
                    }

                    // Read-only indicator
                    if document.isReadOnly {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                            .help("Read-Only Document")
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            // Close Tab Button (Revealed on hover for inactive tabs, always ready on active)
            closeButton
        }
        .padding(.horizontal, 10)
        .frame(height: 29)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(tabBgColor)
        )
        // Elegant top accent indicator bar that stays neatly inside and respects curvature
        .overlay(
            VStack {
                if isActive || document.tagColorHex != nil {
                    Capsule()
                        .fill(accentColor)
                        .frame(
                            width: isActive ? (document.tagColorHex != nil ? 34 : 28) : 22,
                            height: isActive ? 2.5 : 1.8
                        )
                        .padding(.top, 2)
                }
                Spacer()
            }
        )
        // Tab border framing perfectly tracing the continuous rounded shape
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(
                    document.tagColorHex != nil
                        ? accentColor.opacity(isActive ? 0.7 : 0.35)
                        : (isActive
                            ? theme.borderSwiftUIColor.opacity(theme.isDark ? 0.75 : 0.85)
                            : (isHovering ? theme.borderSwiftUIColor.opacity(0.3) : Color.clear)),
                    lineWidth: 1
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .onHover { isHovering = $0 }
        .simultaneousGesture(TapGesture(count: 2).onEnded {
            onRename()
        })
        .contextMenu {
            tabContextMenu
        }
    }

    private var closeButton: some View {
        ZStack {
            if isCloseHovering {
                Circle()
                    .fill(Color(hex: "#ff5f56"))
                    .frame(width: 14, height: 14)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 14, height: 14)
            }

            Image(systemName: "xmark")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(
                    isCloseHovering
                        ? .white
                        : (isActive
                            ? (theme.isDark ? Color.white.opacity(0.65) : Color.black.opacity(0.55))
                            : (isHovering ? (theme.isDark ? Color.white.opacity(0.4) : Color.black.opacity(0.4)) : Color.clear))
                )
        }
        .frame(width: 16, height: 16)
        .contentShape(Circle())
        .onHover { isCloseHovering = $0 }
        .onTapGesture {
            onClose()
        }
        .help("\(loc("close_tab")) (⌘W)")
        .opacity(isActive || isHovering ? 1.0 : 0.0)
    }

    @ViewBuilder
    private var tabContextMenu: some View {
        Button(loc("rename_tab") + "...") { onRename() }
        Divider()
        Button(loc("close_tab")) { onClose() }
        Button(loc("close_other_tabs")) { onCloseOthers() }
        Button(loc("close_tabs_to_right")) { onCloseToTheRight() }
        Divider()
        if let url = document.fileURL {
            Button(loc("copy_full_path")) {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(url.path, forType: .string)
            }
            Button(loc("reveal_in_finder")) {
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
            Divider()
        }
        Menu(loc("tab_color")) {
            Button(loc("no_color")) { document.tagColorHex = nil }
            Divider()
            Button("🔴 Red") { document.tagColorHex = "#ff5f57" }
            Button("🟠 Coral") { document.tagColorHex = "#fe942e" }
            Button("🟡 Amber") { document.tagColorHex = "#fdbc40" }
            Button("🟢 Emerald") { document.tagColorHex = "#28c840" }
            Button("🟢 Teal") { document.tagColorHex = "#20c997" }
            Button("🔵 Sky Blue") { document.tagColorHex = "#528bff" }
            Button("🟣 Indigo") { document.tagColorHex = "#6366f1" }
            Button("🟣 Purple") { document.tagColorHex = "#b362ff" }
            Button("🌸 Pink") { document.tagColorHex = "#ec4899" }
            Button("⚪ Gray") { document.tagColorHex = "#808080" }
            Divider()
            Button(loc("custom_color") + "...") {
                onRename()
            }
        }
    }

    private var fileIconInfo: (name: String, color: Color) {
        switch document.language.id {
        case "swift":
            return ("swift", Color(hex: "#f05138"))
        case "python":
            return ("chevron.left.forwardslash.chevron.right", Color(hex: "#3572a5"))
        case "javascript", "typescript":
            return ("curlybraces.square.fill", Color(hex: "#f7df1e"))
        case "cpp", "c", "objc":
            return ("c.square.fill", Color(hex: "#6866fb"))
        case "rust":
            return ("gearshape.2.fill", Color(hex: "#dea584"))
        case "html", "css":
            return ("globe", Color(hex: "#e34c26"))
        case "markdown":
            return ("doc.richtext.fill", Color(hex: "#458588"))
        case "json", "yaml", "xml", "toml":
            return ("curlybraces", Color(hex: "#83a598"))
        case "lua":
            return ("moon.stars.fill", Color(hex: "#000080"))
        case "sql":
            return ("cylinder.split.1x2.fill", Color(hex: "#e38c00"))
        default:
            return ("doc.text.fill", Color(white: 0.65))
        }
    }
}

// MARK: - Shape: Top Rounded Rectangle (macOS 11.0+ Compatible)

public struct TopRoundedRectangle: Shape {
    public var radius: CGFloat = 6

    public init(radius: CGFloat = 6) {
        self.radius = radius
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
