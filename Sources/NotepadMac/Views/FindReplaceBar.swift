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
            findRow
            replaceRow
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
        .onReceive(NotificationCenter.default.publisher(for: .notepadSearchStatusUpdate)) { notif in
            if let status = notif.userInfo?["status"] as? String {
                self.searchStatus = status
            }
        }
    }

    // MARK: - Find Row

    private var findRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.blue.opacity(0.8))
                .font(.system(size: 11))

            HStack(spacing: 4) {
                TextField(loc("find"), text: $documentManager.searchQuery, onCommit: {
                    findNext()
                })
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 12))

                if !documentManager.searchQuery.isEmpty {
                    Button(action: { documentManager.searchQuery = "" }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(NSColor.textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(
                        !documentManager.searchQuery.isEmpty
                            ? Color.blue.opacity(0.5)
                            : Color.gray.opacity(0.25),
                        lineWidth: 1
                    )
            )
            .frame(minWidth: 160, maxWidth: 260)

            // Search options toggles
            ToggleOptionButton(title: "Aa", tooltip: loc("match_case"), isOn: $documentManager.isMatchCase)
            ToggleOptionButton(title: "\\b", tooltip: loc("whole_word"), isOn: $documentManager.isWholeWord)
            ToggleOptionButton(title: ".*", tooltip: loc("regex"), isOn: $documentManager.isRegex)
            ToggleOptionButton(title: "↩", tooltip: loc("wrap_around"), isOn: $documentManager.isWrapAround)

            Divider().frame(height: 16)

            // Navigation Buttons
            Button(loc("find_prev")) {
                findPrevious()
            }
            .buttonStyle(SecondaryButtonStyle())
            .font(.system(size: 11))

            Button(loc("find_next")) {
                findNext()
            }
            .buttonStyle(ProminentButtonStyle())
            .font(.system(size: 11))

            Button(action: countMatches) {
                Image(systemName: "number")
                    .font(.system(size: 10))
            }
            .buttonStyle(SecondaryButtonStyle())
            .help(loc("count_matches"))

            if !searchStatus.isEmpty {
                Text(searchStatus)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(statusColor)
                    .lineLimit(1)
            }

            Spacer()

            // Open Full Dialog Button
            Button(
                action: {
                    documentManager.isFindReplaceDialogPresented = true
                },
                label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .frame(width: 18, height: 18)
                }
            )
            .buttonStyle(PlainButtonStyle())
            .help(loc("find_replace_hub"))

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
            .help(loc("close"))
        }
    }

    // MARK: - Replace Row

    private var replaceRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundColor(.orange.opacity(0.85))
                .font(.system(size: 11))

            HStack(spacing: 4) {
                TextField(loc("replace"), text: $documentManager.replaceQuery, onCommit: {
                    replaceNext()
                })
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 12))

                if !documentManager.replaceQuery.isEmpty {
                    Button(action: { documentManager.replaceQuery = "" }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(NSColor.textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )
            .frame(minWidth: 160, maxWidth: 260)

            Button(loc("replace_next")) {
                replaceNext()
            }
            .buttonStyle(SecondaryButtonStyle())
            .font(.system(size: 11))

            Button(loc("replace_all")) {
                replaceAll()
            }
            .buttonStyle(SecondaryButtonStyle())
            .font(.system(size: 11))

            Spacer()
        }
    }

    private var statusColor: Color {
        let status = searchStatus.lowercased()
        if status.contains("not found") || status.contains("no match") || status.contains("invalid") {
            return .red
        }
        if status.contains("found") || status.contains("replaced") || status.contains("count:") {
            return .green
        }
        return .secondary
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
                "isRegex": documentManager.isRegex,
                "wrap": documentManager.isWrapAround
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
                "isRegex": documentManager.isRegex,
                "wrap": documentManager.isWrapAround
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

    private func countMatches() {
        guard !documentManager.searchQuery.isEmpty else { return }
        NotificationCenter.default.post(
            name: .notepadCountOccurrences,
            object: nil,
            userInfo: [
                "query": documentManager.searchQuery,
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
                    .frame(width: 24, height: 22)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isOn ? Color.blue : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isOn ? Color.blue : Color.gray.opacity(0.3), lineWidth: 0.8)
                    )
            }
        )
        .buttonStyle(PlainButtonStyle())
        .help(tooltip)
    }
}
