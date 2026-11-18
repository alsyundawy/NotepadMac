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

public struct FindReplaceDialogView: View {
    @ObservedObject var documentManager: DocumentManager

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    private var theme: Theme {
        documentManager.activeTheme
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider().background(Color.white.opacity(0.12))
            mainContentArea
            Divider().background(Color.white.opacity(0.12))
            statusFooter
        }
        .frame(
            width: 550,
            height: documentManager.findDialogTab == 1 ? 370 : (documentManager.findDialogTab == 2 ? 340 : 325)
        )
        .background(Color(red: 0.13, green: 0.15, blue: 0.18))
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
        .onReceive(NotificationCenter.default.publisher(for: .notepadSearchStatusUpdate)) { notif in
            if let status = notif.userInfo?["status"] as? String {
                documentManager.searchStatus = status
            }
        }
    }

    // MARK: - Header Bar with Sliding Tab Switcher

    private var headerBar: some View {
        HStack {
            // Elegant Multi-tab Selector (Find, Replace, Mark)
            HStack(spacing: 4) {
                TabPillButton(
                    title: loc("find"),
                    icon: "magnifyingglass",
                    isSelected: documentManager.findDialogTab == 0
                ) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        documentManager.findDialogTab = 0
                    }
                }

                TabPillButton(
                    title: loc("replace"),
                    icon: "arrow.triangle.2.circlepath",
                    isSelected: documentManager.findDialogTab == 1
                ) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        documentManager.findDialogTab = 1
                    }
                }

                TabPillButton(
                    title: loc("mark"),
                    icon: "bookmark.fill",
                    isSelected: documentManager.findDialogTab == 2
                ) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        documentManager.findDialogTab = 2
                    }
                }
            }
            .padding(3)
            .background(Color.black.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
            )

            Spacer()

            // Close sheet button
            Button(action: {
                documentManager.isFindReplaceDialogPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color.white.opacity(0.5))
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut(.cancelAction)
            .help("Close (Esc)")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(red: 0.11, green: 0.13, blue: 0.15))
    }

    // MARK: - Main Content Area

    private var mainContentArea: some View {
        HStack(alignment: .top, spacing: 18) {
            // Left: Input fields and options
            leftInputAndOptionsColumn
                .frame(maxWidth: .infinity, alignment: .leading)

            // Vertical divider separating inputs from actions
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1)
                .padding(.vertical, 4)

            // Right: Standardized Action Buttons
            rightActionButtonsColumn
                .frame(width: 116)
        }
        .padding(16)
    }

    // MARK: - Left Column: Inputs & Options

    private var leftInputAndOptionsColumn: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Find What Input
            VStack(alignment: .leading, spacing: 5) {
                Text("FIND WHAT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.6))

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.45))

                    TextField("Enter search term...", text: $documentManager.searchQuery, onCommit: {
                        triggerFindNext()
                    })
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 12))
                    .foregroundColor(.white)

                    if !documentManager.searchQuery.isEmpty {
                        Button(action: { documentManager.searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 10)
                .frame(height: 30)
                .background(Color.black.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(
                            !documentManager.searchQuery.isEmpty
                                ? Color.blue.opacity(0.6)
                                : Color.white.opacity(0.15),
                            lineWidth: 1
                        )
                )
            }

            // Replace With Input (Animated visibility for Replace tab)
            if documentManager.findDialogTab == 1 {
                VStack(alignment: .leading, spacing: 5) {
                    Text("REPLACE WITH")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.6))

                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 11))
                            .foregroundColor(Color.white.opacity(0.45))

                        TextField("Enter replacement text...", text: $documentManager.replaceQuery, onCommit: {
                            triggerReplaceNext()
                        })
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 12))
                        .foregroundColor(.white)

                        if !documentManager.replaceQuery.isEmpty {
                            Button(action: { documentManager.replaceQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.white.opacity(0.5))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 30)
                    .background(Color.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Search Options Box
            VStack(alignment: .leading, spacing: 8) {
                Text("SEARCH OPTIONS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.6))

                VStack(spacing: 6) {
                    HStack(spacing: 16) {
                        CustomOptionCheckbox(
                            title: loc("match_case"),
                            badge: "Aa",
                            isOn: $documentManager.isMatchCase
                        )
                        CustomOptionCheckbox(
                            title: loc("whole_word"),
                            badge: "\\b",
                            isOn: $documentManager.isWholeWord
                        )
                    }

                    HStack(spacing: 16) {
                        CustomOptionCheckbox(
                            title: loc("regex"),
                            badge: ".*",
                            isOn: $documentManager.isRegex
                        )
                        CustomOptionCheckbox(
                            title: loc("wrap_around"),
                            badge: "↩",
                            isOn: $documentManager.isWrapAround
                        )
                    }
                }
                .padding(10)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
            }

            // Search Direction Segment
            HStack(spacing: 10) {
                Text("Direction:")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.75))

                HStack(spacing: 2) {
                    Button(action: { documentManager.searchDirectionUp = false }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 10))
                            Text("Down")
                                .font(.system(size: 11, weight: !documentManager.searchDirectionUp ? .semibold : .regular))
                        }
                        .foregroundColor(!documentManager.searchDirectionUp ? .white : Color.white.opacity(0.6))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(!documentManager.searchDirectionUp ? Color.blue.opacity(0.4) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { documentManager.searchDirectionUp = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 10))
                            Text("Up")
                                .font(.system(size: 11, weight: documentManager.searchDirectionUp ? .semibold : .regular))
                        }
                        .foregroundColor(documentManager.searchDirectionUp ? .white : Color.white.opacity(0.6))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(documentManager.searchDirectionUp ? Color.blue.opacity(0.4) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(2)
                .background(Color.black.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
        }
    }

    // MARK: - Right Column: Standardized Actions

    private var rightActionButtonsColumn: some View {
        VStack(spacing: 7) {
            // Find Next (Primary Action)
            Button(action: triggerFindNext) {
                HStack(spacing: 5) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11, weight: .bold))
                    Text(loc("find_next"))
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 27)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#0969da"), Color(hex: "#044289")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            .keyboardShortcut(.defaultAction)

            // Find Prev
            DialogSecondaryButton(title: loc("find_prev"), icon: "chevron.up") {
                triggerFindPrevious()
            }

            // Replace actions (only when in Replace tab)
            if documentManager.findDialogTab == 1 {
                DialogSecondaryButton(title: loc("replace_next"), icon: "arrow.triangle.2.circlepath") {
                    triggerReplaceNext()
                }

                DialogSecondaryButton(title: loc("replace_all"), icon: "arrow.triangle.2.circlepath.circle.fill") {
                    triggerReplaceAll()
                }
            }

            // Count Matches
            DialogSecondaryButton(title: loc("count_matches"), icon: "number") {
                triggerCount()
            }

            Spacer(minLength: 8)

            // Close dialog
            DialogSecondaryButton(title: loc("close"), icon: "xmark") {
                documentManager.isFindReplaceDialogPresented = false
            }
        }
    }

    // MARK: - Status Footer

    private var statusFooter: some View {
        HStack(spacing: 8) {
            Image(systemName: statusIcon)
                .font(.system(size: 11))
                .foregroundColor(statusColor)

            Text(documentManager.searchStatus.isEmpty ? "Ready to search" : documentManager.searchStatus)
                .font(.system(size: 11))
                .foregroundColor(statusColor)
                .lineLimit(1)

            Spacer()

            // Active flags badges
            HStack(spacing: 4) {
                if documentManager.isMatchCase {
                    StatusOptionBadge(title: "Match Case")
                }
                if documentManager.isWholeWord {
                    StatusOptionBadge(title: "Whole Word")
                }
                if documentManager.isRegex {
                    StatusOptionBadge(title: "Regex")
                }
                if documentManager.isWrapAround {
                    StatusOptionBadge(title: "Wrap")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(red: 0.10, green: 0.11, blue: 0.13))
    }

    private var statusIcon: String {
        let status = documentManager.searchStatus.lowercased()
        if status.contains("not found") || status.contains("no match") {
            return "exclamationmark.circle.fill"
        }
        if status.contains("found") || status.contains("replaced") || status.contains("count:") {
            return "checkmark.circle.fill"
        }
        return "info.circle"
    }

    private var statusColor: Color {
        let status = documentManager.searchStatus.lowercased()
        if status.contains("not found") || status.contains("no match") {
            return Color(hex: "#ff7b72")
        }
        if status.contains("found") || status.contains("replaced") || status.contains("count:") {
            return Color(hex: "#7ee787")
        }
        return Color.white.opacity(0.65)
    }

    // MARK: - Search Triggers

    private func triggerFindNext() {
        guard !documentManager.searchQuery.isEmpty else { return }
        NotificationCenter.default.post(
            name: documentManager.searchDirectionUp ? .notepadFindPrevious : .notepadFindNext,
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

    private func triggerFindPrevious() {
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

    private func triggerReplaceNext() {
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

    private func triggerReplaceAll() {
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

    private func triggerCount() {
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

// MARK: - Helper Views & Components

private struct TabPillButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : Color.white.opacity(0.65))
            .padding(.horizontal, 14)
            .padding(.vertical, 5)
            .background(isSelected ? Color.blue.opacity(0.8) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

private struct CustomOptionCheckbox: View {
    let title: String
    let badge: String
    @Binding var isOn: Bool

    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack(spacing: 7) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(isOn ? Color.blue : Color.white.opacity(0.3), lineWidth: 1.2)
                        .frame(width: 14, height: 14)

                    if isOn {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.blue)
                            .frame(width: 14, height: 14)

                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(isOn ? .white : Color.white.opacity(0.8))

                Spacer()

                Text(badge)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(isOn ? Color(hex: "#58a6ff") : Color.white.opacity(0.35))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

private struct DialogSecondaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    @State private var isHovering: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isHovering ? .white : Color.white.opacity(0.85))
            .frame(maxWidth: .infinity)
            .frame(height: 26)
            .background(isHovering ? Color.white.opacity(0.15) : Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.white.opacity(isHovering ? 0.25 : 0.12), lineWidth: 0.8)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}

private struct StatusOptionBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(Color(hex: "#58a6ff"))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}
