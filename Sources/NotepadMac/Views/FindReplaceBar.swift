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

public struct FindReplaceBar: View {
    @ObservedObject var documentManager: DocumentManager
    @State private var searchStatus: String = ""

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    public var body: some View {
        VStack(spacing: 6) {
            // Find Row
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))

                TextField("Find", text: $documentManager.searchQuery, onCommit: {
                    findNext()
                })
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 12))
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(documentManager.activeTheme.isDark ? Color(white: 0.15) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(documentManager.activeTheme.borderSwiftUIColor, lineWidth: 1)
                )
                .frame(minWidth: 160)

                // Search options toggles
                ToggleOptionButton(title: "Aa", tooltip: "Match Case", isOn: $documentManager.isMatchCase)
                ToggleOptionButton(title: "\\b", tooltip: "Match Whole Word", isOn: $documentManager.isWholeWord)
                ToggleOptionButton(title: ".*", tooltip: "Use Regular Expression", isOn: $documentManager.isRegex)

                Divider().frame(height: 16)

                // Navigation Buttons
                Button("Previous") {
                    findPrevious()
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.system(size: 11))

                Button("Next") {
                    findNext()
                }
                .buttonStyle(ProminentButtonStyle())
                .font(.system(size: 11))

                if !searchStatus.isEmpty {
                    Text(searchStatus)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Close button
                Button(
                    action: {
                        withAnimation {
                            documentManager.isFindReplaceBarVisible = false
                        }
                    },
                    label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 18, height: 18)
                    }
                )
                .buttonStyle(PlainButtonStyle())
            }

            // Replace Row
            HStack(spacing: 8) {
                Image(systemName: "arrow.2.squarepath")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))

                TextField("Replace", text: $documentManager.replaceQuery, onCommit: {
                    replaceNext()
                })
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 12))
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(documentManager.activeTheme.isDark ? Color(white: 0.15) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(documentManager.activeTheme.borderSwiftUIColor, lineWidth: 1)
                )
                .frame(minWidth: 160)

                Button("Replace") {
                    replaceNext()
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.system(size: 11))

                Button("Replace All") {
                    replaceAll()
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.system(size: 11))

                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(documentManager.activeTheme.tabBarBgSwiftUIColor)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(documentManager.activeTheme.borderSwiftUIColor),
            alignment: .bottom
        )
        .onReceive(NotificationCenter.default.publisher(for: .notepadSearchStatusUpdate)) { notif in
            if let status = notif.userInfo?["status"] as? String {
                self.searchStatus = status
            }
        }
    }

    // MARK: - Search Operations

    private func findNext() {
        guard !documentManager.searchQuery.isEmpty else { return }
        NotificationCenter.default.post(
            name: .notepadFindNext,
            object: nil,
            userInfo: [
                "query": documentManager.searchQuery,
                "matchCase": documentManager.isMatchCase,
                "wholeWord": documentManager.isWholeWord,
                "isRegex": documentManager.isRegex
            ]
        )
    }

    private func findPrevious() {
        guard !documentManager.searchQuery.isEmpty else { return }
        NotificationCenter.default.post(
            name: .notepadFindPrevious,
            object: nil,
            userInfo: [
                "query": documentManager.searchQuery,
                "matchCase": documentManager.isMatchCase,
                "wholeWord": documentManager.isWholeWord,
                "isRegex": documentManager.isRegex
            ]
        )
    }

    private func replaceNext() {
        guard !documentManager.searchQuery.isEmpty else { return }
        NotificationCenter.default.post(
            name: .notepadReplaceNext,
            object: nil,
            userInfo: [
                "query": documentManager.searchQuery,
                "replace": documentManager.replaceQuery,
                "matchCase": documentManager.isMatchCase,
                "wholeWord": documentManager.isWholeWord,
                "isRegex": documentManager.isRegex,
                "wrap": documentManager.isWrapAround
            ]
        )
    }

    private func replaceAll() {
        guard !documentManager.searchQuery.isEmpty else { return }
        NotificationCenter.default.post(
            name: .notepadReplaceAll,
            object: nil,
            userInfo: [
                "query": documentManager.searchQuery,
                "replace": documentManager.replaceQuery,
                "matchCase": documentManager.isMatchCase,
                "wholeWord": documentManager.isWholeWord,
                "isRegex": documentManager.isRegex
            ]
        )
    }
}

public struct ToggleOptionButton: View {
    public let title: String
    public let tooltip: String
    @Binding public var isOn: Bool

    public var body: some View {
        Button(
            action: { isOn.toggle() },
            label: {
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(isOn ? .white : .secondary)
                    .frame(width: 22, height: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(isOn ? Color.blue : Color.white.opacity(0.08))
                    )
            }
        )
        .buttonStyle(PlainButtonStyle())
        .help(tooltip)
    }
}
