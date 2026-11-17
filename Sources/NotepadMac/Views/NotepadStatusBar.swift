//
//  NotepadStatusBar.swift
//  NotepadMac
//
//  Status bar showing cursor position, encoding, line ending, and lexer
//

import SwiftUI

public struct NotepadStatusBar: View {
    @ObservedObject var documentManager: DocumentManager

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    private var theme: Theme {
        documentManager.activeTheme
    }

    private var secondaryTextColor: Color {
        theme.isDark ? Color(white: 0.7) : Color(hex: "#57606a")
    }

    private var primaryTextColor: Color {
        theme.isDark ? Color(white: 0.9) : Color(hex: "#24292f")
    }

    private var separatorColor: Color {
        theme.isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Left Status
            if let doc = documentManager.activeDocument {
                HStack(spacing: 6) {
                    Circle()
                        .fill(doc.isModified ? Color.orange : Color.green)
                        .frame(width: 6, height: 6)
                    Text(doc.isModified ? "Modified" : "Ready")
                        .font(.system(size: 11))
                        .foregroundColor(secondaryTextColor)

                    Text("•")
                        .foregroundColor(separatorColor)

                    Text("\(doc.lineCount) lines")
                        .font(.system(size: 11))
                        .foregroundColor(secondaryTextColor)

                    Text("•")
                        .foregroundColor(separatorColor)

                    Text(doc.fileSizeDescription)
                        .font(.system(size: 11))
                        .foregroundColor(secondaryTextColor)
                }
            } else {
                Text("Ready")
                    .font(.system(size: 11))
                    .foregroundColor(secondaryTextColor)
            }

            Spacer()

            // Right Status (Cursor & Encoding & Lexer)
            if let doc = documentManager.activeDocument {
                HStack(spacing: 12) {
                    // Line & Column
                    Text("Ln \(doc.cursorLine), Col \(doc.cursorColumn)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(secondaryTextColor)

                    if doc.selectionLength > 0 {
                        Text("(\(doc.selectionLength) sel)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(theme.isDark ? .blue : Color(hex: "#0969da"))
                    }

                    Divider()
                        .frame(height: 12)
                        .background(theme.borderSwiftUIColor)

                    // Line Ending Menu
                    Menu {
                        ForEach(LineEnding.allCases) { ending in
                            Button(ending.rawValue) {
                                doc.lineEnding = ending
                            }
                        }
                    } label: {
                        Text(doc.lineEnding.rawValue)
                            .font(.system(size: 11))
                            .foregroundColor(secondaryTextColor)
                    }
                    .menuStyle(BorderlessButtonMenuStyle())

                    Divider()
                        .frame(height: 12)
                        .background(theme.borderSwiftUIColor)

                    // Encoding Menu
                    Menu {
                        Button("UTF-8") { doc.encoding = .utf8 }
                        Button("UTF-16") { doc.encoding = .utf16 }
                        Button("ASCII") { doc.encoding = .ascii }
                        Button("ISO-Latin-1") { doc.encoding = .isoLatin1 }
                    } label: {
                        Text(doc.encodingName)
                            .font(.system(size: 11))
                            .foregroundColor(secondaryTextColor)
                    }
                    .menuStyle(BorderlessButtonMenuStyle())

                    Divider()
                        .frame(height: 12)
                        .background(theme.borderSwiftUIColor)

                    // Lexer Language Menu
                    Menu {
                        Button(LexerRegistry.shared.plainTextLanguage.displayName) {
                            doc.language = LexerRegistry.shared.plainTextLanguage
                        }

                        Divider()

                        ForEach(LexerRegistry.shared.alphabeticalGroups) { group in
                            Menu(group.letter) {
                                ForEach(group.languages) { lang in
                                    Button(lang.displayName) {
                                        doc.language = lang
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(doc.language.displayName)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(primaryTextColor)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 8))
                                .foregroundColor(secondaryTextColor)
                        }
                    }
                    .menuStyle(BorderlessButtonMenuStyle())

                    Divider()
                        .frame(height: 12)
                        .background(theme.borderSwiftUIColor)

                    // Quick Find & Replace Icons
                    HStack(spacing: 6) {
                        Button(action: {
                            documentManager.findDialogTab = 0
                            documentManager.isFindReplaceDialogPresented = true
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 11))
                                .foregroundColor(secondaryTextColor)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Find... (⌘F)")

                        Button(action: {
                            documentManager.findDialogTab = 1
                            documentManager.isFindReplaceDialogPresented = true
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 11))
                                .foregroundColor(secondaryTextColor)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Replace... (⌥⌘F)")
                    }

                    Divider()
                        .frame(height: 12)
                        .background(theme.borderSwiftUIColor)

                    // Word Wrap Toggle Icon
                    Button(action: {
                        documentManager.isWordWrapEnabled.toggle()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "text.word.spacing")
                                .font(.system(size: 10))
                            Text(documentManager.isWordWrapEnabled ? "Wrap" : "No Wrap")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(
                            documentManager.isWordWrapEnabled
                                ? (theme.isDark ? .blue : Color(hex: "#0969da"))
                                : secondaryTextColor
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Toggle Word Wrap (⌥Z)")

                    Divider()
                        .frame(height: 12)
                        .background(theme.borderSwiftUIColor)

                    // Zoom Controls & Icons
                    HStack(spacing: 4) {
                        Button(action: {
                            doc.zoomOffset -= 1
                        }) {
                            Image(systemName: "minus.magnifyingglass")
                                .font(.system(size: 10))
                                .foregroundColor(secondaryTextColor)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Zoom Out (⌘-)")

                        Button(action: {
                            doc.zoomOffset = 0
                        }) {
                            let zoomPercent = max(10, 100 + doc.zoomOffset * 10)
                            Text("\(zoomPercent)%")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(primaryTextColor)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Reset Zoom (⌘0)")

                        Button(action: {
                            doc.zoomOffset += 1
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.system(size: 10))
                                .foregroundColor(secondaryTextColor)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Zoom In (⌘+)")
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(theme.statusBarBgSwiftUIColor)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(theme.borderSwiftUIColor),
            alignment: .top
        )
    }
}
