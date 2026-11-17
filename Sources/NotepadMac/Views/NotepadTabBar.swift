//
//  NotepadTabBar.swift
//  NotepadMac
//
//  Multi-tab document bar with drag reordering, color tagging, and dirty indicators
//

import SwiftUI

public struct NotepadTabBar: View {
    @ObservedObject var documentManager: DocumentManager

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(documentManager.documents) { doc in
                    TabItemView(
                        document: doc,
                        isActive: doc.id == documentManager.activeDocumentID,
                        theme: documentManager.activeTheme,
                        onSelect: {
                            documentManager.activeDocumentID = doc.id
                        },
                        onClose: {
                            documentManager.closeDocument(id: doc.id)
                        },
                        onCloseOthers: {
                            documentManager.closeOtherDocuments(except: doc.id)
                        }
                    )
                }

                addTabButton
                Spacer()
            }
            .padding(.horizontal, 6)
            .padding(.top, 4)
        }
        .background(documentManager.activeTheme.tabBarBgSwiftUIColor)
        .overlay(bottomBorder, alignment: .bottom)
    }

    private var addTabButton: some View {
        Button(
            action: { documentManager.newDocument() },
            label: {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(
                        documentManager.activeTheme.isDark
                            ? Color(white: 0.7)
                            : Color(hex: "#57606a")
                    )
                    .frame(width: 24, height: 26)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                documentManager.activeTheme.isDark
                                    ? Color.white.opacity(0.05)
                                    : Color.black.opacity(0.05)
                            )
                    )
            }
        )
        .buttonStyle(PlainButtonStyle())
        .padding(.leading, 4)
        .help("New Tab (⌘N)")
    }

    private var bottomBorder: some View {
        Rectangle()
            .fill(documentManager.activeTheme.borderSwiftUIColor)
            .frame(height: 1)
    }
}

public struct TabItemView: View {
    @ObservedObject var document: EditorDocument
    public let isActive: Bool
    public let theme: Theme
    public let onSelect: () -> Void
    public let onClose: () -> Void
    public let onCloseOthers: () -> Void

    @State private var isHovering: Bool = false
    @State private var isCloseHovering: Bool = false

    private var iconColor: Color {
        if isActive {
            return theme.isDark ? .blue : Color(hex: "#0969da")
        }
        return theme.isDark ? Color(white: 0.6) : Color(hex: "#57606a")
    }

    private var titleColor: Color {
        if isActive {
            return theme.foregroundSwiftUIColor
        }
        if isHovering {
            return theme.isDark ? Color(white: 0.95) : Color.black
        }
        return theme.isDark ? Color(white: 0.7) : Color(hex: "#57606a")
    }

    private var closeButtonColor: Color {
        if isCloseHovering {
            return theme.isDark ? .white : .black
        }
        return theme.isDark ? Color(white: 0.5) : Color(hex: "#8c959f")
    }

    private var closeButtonBgColor: Color {
        guard isCloseHovering else { return Color.clear }
        return theme.isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.1)
    }

    private var tabBgColor: Color {
        if isActive {
            return theme.activeTabBgSwiftUIColor
        }
        if isHovering {
            return theme.isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.05)
        }
        return Color.clear
    }

    public var body: some View {
        HStack(spacing: 6) {
            if let hex = document.tagColorHex {
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: 7, height: 7)
            }

            Image(systemName: fileIconName)
                .font(.system(size: 11))
                .foregroundColor(iconColor)

            Text(document.title)
                .font(.system(size: 11, weight: isActive ? .medium : .regular))
                .foregroundColor(titleColor)
                .lineLimit(1)

            if document.isModified {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 6, height: 6)
                    .help("Document has unsaved changes")
            }

            if document.isReadOnly {
                Image(systemName: "lock.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                    .help("Read-Only Document")
            }

            Button(
                action: onClose,
                label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(closeButtonColor)
                        .frame(width: 14, height: 14)
                        .background(Circle().fill(closeButtonBgColor))
                }
            )
            .buttonStyle(PlainButtonStyle())
            .onHover { isCloseHovering = $0 }
            .help("Close Tab (⌘W)")
        }
        .padding(.horizontal, 10)
        .frame(height: 28)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(tabBgColor)
        )
        .overlay(
            VStack {
                if isActive {
                    Rectangle()
                        .fill(theme.isDark ? Color.blue : Color(hex: "#0969da"))
                        .frame(height: 2)
                        .padding(.horizontal, 4)
                }
                Spacer()
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isActive ? theme.borderSwiftUIColor : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .onHover { isHovering = $0 }
        .contextMenu {
            tabContextMenu
        }
    }

    @ViewBuilder
    private var tabContextMenu: some View {
        Button("Close Tab") { onClose() }
        Button("Close Other Tabs") { onCloseOthers() }
        Divider()
        Menu("Color Tag") {
            Button("None") { document.tagColorHex = nil }
            Button("Red") { document.tagColorHex = "#ff5f57" }
            Button("Orange") { document.tagColorHex = "#fe942e" }
            Button("Yellow") { document.tagColorHex = "#fdbc40" }
            Button("Green") { document.tagColorHex = "#28c840" }
            Button("Blue") { document.tagColorHex = "#528bff" }
            Button("Purple") { document.tagColorHex = "#b362ff" }
        }
    }

    private var fileIconName: String {
        switch document.language.id {
        case "markdown": return "doc.richtext"
        case "json", "yaml", "xml": return "curlybraces"
        case "cpp", "c", "objc": return "c.square"
        case "swift": return "swift"
        case "python": return "chevron.left.forwardslash.chevron.right"
        case "lua": return "moon.stars"
        case "html", "css", "javascript": return "globe"
        default: return "doc.text"
        }
    }
}
