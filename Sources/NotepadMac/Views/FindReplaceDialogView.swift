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

    public var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider().background(Color.white.opacity(0.12))
            tabSelector
            Divider().background(Color.white.opacity(0.12))
            mainContentArea
            Divider().background(Color.white.opacity(0.12))
            statusFooter
        }
        .frame(width: 660, height: 490)
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
        .onReceive(NotificationCenter.default.publisher(for: .notepadSearchStatusUpdate)) { notif in
            if let status = notif.userInfo?["status"] as? String {
                documentManager.searchStatus = status
            }
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Image(systemName: headerIcon)
                .foregroundColor(.blue)
                .font(.system(size: 15, weight: .bold))

            Text(loc("find_replace_hub"))
                .font(.system(size: 14, weight: .bold))

            Spacer()

            Button(action: {
                documentManager.isFindReplaceDialogPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut(.cancelAction)
            .help("Close (Esc)")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var headerIcon: String {
        switch documentManager.findDialogTab {
        case 1: return "arrow.triangle.2.circlepath.circle.fill"
        case 2: return "bookmark.circle.fill"
        default: return "magnifyingglass.circle.fill"
        }
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        Picker("", selection: $documentManager.findDialogTab) {
            Text(loc("find")).tag(0)
            Text(loc("replace")).tag(1)
            Text(loc("mark")).tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }

    // MARK: - Main Content Area

    private var mainContentArea: some View {
        HStack(alignment: .top, spacing: 16) {
            leftInputAndOptionsColumn
                .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1)
                .padding(.vertical, 2)

            rightActionButtonsColumn
                .frame(width: 140)
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Left Column: Inputs & Options

    private var leftInputAndOptionsColumn: some View {
        VStack(alignment: .leading, spacing: 12) {
            inputsCardSection

            optionsCardSection

            secondaryOptionsSection

            Spacer(minLength: 4)

            documentContextBadge
        }
    }

    private var inputsCardSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Find / Mark What Input
            VStack(alignment: .leading, spacing: 4) {
                Text(documentManager.findDialogTab == 2 ? loc("mark_what") : loc("find_what"))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Image(systemName: documentManager.findDialogTab == 2 ? "bookmark.fill" : "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundColor(.blue.opacity(0.8))

                    TextField(loc("search_field_placeholder"), text: $documentManager.searchQuery, onCommit: {
                        if documentManager.findDialogTab == 2 {
                            triggerMarkAll()
                        } else {
                            triggerFindNext()
                        }
                    })
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 12))

                    if !documentManager.searchQuery.isEmpty {
                        Button(action: { documentManager.searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 10)
                .frame(height: 32)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(
                            !documentManager.searchQuery.isEmpty
                                ? Color.blue.opacity(0.6)
                                : Color.gray.opacity(0.25),
                            lineWidth: 1
                        )
                )
            }

            // Replace With Input (in Replace tab)
            if documentManager.findDialogTab == 1 {
                VStack(alignment: .leading, spacing: 4) {
                    Text(loc("replace_with"))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 11))
                            .foregroundColor(.orange.opacity(0.85))

                        TextField(loc("replace_field_placeholder"), text: $documentManager.replaceQuery, onCommit: {
                            triggerReplaceNext()
                        })
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 12))

                        if !documentManager.replaceQuery.isEmpty {
                            Button(action: { documentManager.replaceQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else if documentManager.findDialogTab == 2 {
                // Informative helper text for Mark tab
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue.opacity(0.8))
                        .font(.system(size: 11))
                    Text("Highlights matching occurrences and optionally bookmarks lines in the margin.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }
        }
    }

    private var optionsCardSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(loc("search_options"))
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)

            VStack(spacing: 6) {
                HStack(spacing: 12) {
                    OptionToggleCard(
                        title: loc("match_case"),
                        badge: "Aa",
                        isOn: $documentManager.isMatchCase
                    )
                    OptionToggleCard(
                        title: loc("whole_word"),
                        badge: "\\b",
                        isOn: $documentManager.isWholeWord
                    )
                }

                HStack(spacing: 12) {
                    OptionToggleCard(
                        title: loc("regex"),
                        badge: ".*",
                        isOn: $documentManager.isRegex
                    )
                    OptionToggleCard(
                        title: loc("wrap_around"),
                        badge: "↩",
                        isOn: $documentManager.isWrapAround
                    )
                }
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.8)
            )
        }
    }

    @ViewBuilder
    private var secondaryOptionsSection: some View {
        if documentManager.findDialogTab == 2 {
            // Mark Options Card
            VStack(alignment: .leading, spacing: 6) {
                Text("MARK ATTRIBUTES")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    OptionToggleCard(
                        title: loc("bookmark_line"),
                        badge: "🔖",
                        isOn: $documentManager.isBookmarkLine
                    )
                    OptionToggleCard(
                        title: loc("purge_for_each_search"),
                        badge: "🧹",
                        isOn: $documentManager.isPurgeOnSearch
                    )
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.8)
                )
            }
        } else {
            // Direction Selector
            HStack(spacing: 12) {
                Text(loc("direction") + ":")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)

                HStack(spacing: 4) {
                    Button(action: { documentManager.searchDirectionUp = false }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 10))
                            Text(loc("down"))
                                .font(.system(size: 11, weight: !documentManager.searchDirectionUp ? .semibold : .regular))
                        }
                        .foregroundColor(!documentManager.searchDirectionUp ? .white : .secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(!documentManager.searchDirectionUp ? Color.blue : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { documentManager.searchDirectionUp = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 10))
                            Text(loc("up"))
                                .font(.system(size: 11, weight: documentManager.searchDirectionUp ? .semibold : .regular))
                        }
                        .foregroundColor(documentManager.searchDirectionUp ? .white : .secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(documentManager.searchDirectionUp ? Color.blue : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(2)
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
        }
    }

    private var documentContextBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.text")
                .foregroundColor(.secondary)
                .font(.system(size: 10))

            Text(documentManager.activeDocument?.title ?? "Document")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)

            Spacer()

            if let doc = documentManager.activeDocument {
                Text("\(doc.lineCount) lines")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    // MARK: - Right Column: Standardized Actions

    @ViewBuilder
    private var rightActionButtonsColumn: some View {
        VStack(spacing: 8) {
            switch documentManager.findDialogTab {
            case 1:
                replaceTabActions
            case 2:
                markTabActions
            default:
                findTabActions
            }

            Spacer(minLength: 8)

            // Close dialog
            DialogActionSecondaryButton(title: loc("close"), icon: "xmark") {
                documentManager.isFindReplaceDialogPresented = false
            }
            .keyboardShortcut(.cancelAction)
        }
    }

    private var findTabActions: some View {
        VStack(spacing: 8) {
            // Find Next (Primary)
            Button(action: triggerFindNext) {
                HStack(spacing: 5) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11, weight: .bold))
                    Text(loc("find_next"))
                        .font(.system(size: 11, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 28)
            }
            .buttonStyle(ProminentButtonStyle())
            .keyboardShortcut(.defaultAction)

            DialogActionSecondaryButton(title: loc("find_prev"), icon: "chevron.up") {
                triggerFindPrevious()
            }

            DialogActionSecondaryButton(title: loc("count_matches"), icon: "number") {
                triggerCount()
            }
        }
    }

    private var replaceTabActions: some View {
        VStack(spacing: 8) {
            // Replace Next (Primary)
            Button(action: triggerReplaceNext) {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11, weight: .bold))
                    Text(loc("replace_next"))
                        .font(.system(size: 11, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 28)
            }
            .buttonStyle(ProminentButtonStyle())
            .keyboardShortcut(.defaultAction)

            DialogActionSecondaryButton(title: loc("replace_all"), icon: "arrow.triangle.2.circlepath.circle.fill") {
                triggerReplaceAll()
            }

            DialogActionSecondaryButton(title: loc("find_next"), icon: "magnifyingglass") {
                triggerFindNext()
            }

            DialogActionSecondaryButton(title: loc("find_prev"), icon: "chevron.up") {
                triggerFindPrevious()
            }

            DialogActionSecondaryButton(title: loc("count_matches"), icon: "number") {
                triggerCount()
            }
        }
    }

    private var markTabActions: some View {
        VStack(spacing: 8) {
            // Mark All (Primary)
            Button(action: triggerMarkAll) {
                HStack(spacing: 5) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 11, weight: .bold))
                    Text(loc("mark_all"))
                        .font(.system(size: 11, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 28)
            }
            .buttonStyle(ProminentButtonStyle())
            .keyboardShortcut(.defaultAction)

            DialogActionSecondaryButton(title: loc("clear_all_marks"), icon: "trash") {
                triggerClearMarks()
            }

            DialogActionSecondaryButton(title: loc("copy_marked_text"), icon: "doc.on.doc") {
                triggerCopyMarkedText()
            }

            DialogActionSecondaryButton(title: loc("count_matches"), icon: "number") {
                triggerCount()
            }
        }
    }

    // MARK: - Status Footer

    private var statusFooter: some View {
        HStack(spacing: 8) {
            Image(systemName: statusIcon)
                .font(.system(size: 12))
                .foregroundColor(statusColor)

            Text(documentManager.searchStatus.isEmpty ? loc("ready_to_search") : documentManager.searchStatus)
                .font(.system(size: 11))
                .foregroundColor(statusColor)
                .lineLimit(1)

            Spacer()

            // Active flags badges
            HStack(spacing: 4) {
                if documentManager.isMatchCase {
                    StatusFlagPill(title: "Aa")
                }
                if documentManager.isWholeWord {
                    StatusFlagPill(title: "\\b")
                }
                if documentManager.isRegex {
                    StatusFlagPill(title: ".*")
                }
                if documentManager.isWrapAround {
                    StatusFlagPill(title: "↩")
                }
                if documentManager.findDialogTab == 2 && documentManager.isBookmarkLine {
                    StatusFlagPill(title: "🔖")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var statusIcon: String {
        let status = documentManager.searchStatus.lowercased()
        if status.contains("not found") || status.contains("no match") || status.contains("invalid") {
            return "exclamationmark.circle.fill"
        }
        if status.contains("found") || status.contains("replaced") || status.contains("count:") || status.contains("marked") || status.contains("cleared") || status.contains("copied") {
            return "checkmark.circle.fill"
        }
        return "info.circle.fill"
    }

    private var statusColor: Color {
        let status = documentManager.searchStatus.lowercased()
        if status.contains("not found") || status.contains("no match") || status.contains("invalid") {
            return .red
        }
        if status.contains("found") || status.contains("replaced") || status.contains("count:") || status.contains("marked") || status.contains("cleared") || status.contains("copied") {
            return .green
        }
        return .secondary
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

    private func triggerMarkAll() {
        guard !documentManager.searchQuery.isEmpty else { return }
        NotificationCenter.default.post(
            name: .notepadMarkAll,
            object: nil,
            userInfo: [
                "query": documentManager.searchQuery,
                "matchCase": documentManager.isMatchCase,
                "wholeWord": documentManager.isWholeWord,
                "isRegex": documentManager.isRegex,
                "bookmarkLine": documentManager.isBookmarkLine,
                "purge": documentManager.isPurgeOnSearch
            ]
        )
    }

    private func triggerClearMarks() {
        NotificationCenter.default.post(
            name: .notepadClearMarks,
            object: nil
        )
    }

    private func triggerCopyMarkedText() {
        NotificationCenter.default.post(
            name: .notepadCopyMarkedText,
            object: nil
        )
    }
}

// MARK: - Helper Views & Components

private struct OptionToggleCard: View {
    let title: String
    let badge: String
    @Binding var isOn: Bool

    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(isOn ? Color.blue : Color.gray.opacity(0.4), lineWidth: 1.2)
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
                    .foregroundColor(isOn ? .primary : .secondary)

                Spacer()

                Text(badge)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(isOn ? .blue : .secondary.opacity(0.7))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color(NSColor.controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

private struct DialogActionSecondaryButton: View {
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
            .foregroundColor(isHovering ? .primary : .secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 27)
            .background(isHovering ? Color(NSColor.controlBackgroundColor) : Color(NSColor.controlBackgroundColor).opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.gray.opacity(isHovering ? 0.35 : 0.18), lineWidth: 0.8)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}

private struct StatusFlagPill: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(.blue)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}
