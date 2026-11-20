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

public struct CrashRecoverySheet: View {
    @ObservedObject public var documentManager: DocumentManager
    @State private var selectedSnapshotIds: Set<UUID> = []
    @State private var previewedSnapshot: RecoverySnapshot?

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()

            VStack(alignment: .leading, spacing: 12) {
                infoBanner
                snapshotListSection
                if let preview = previewedSnapshot {
                    previewSection(for: preview)
                }
            }
            .padding(16)

            Spacer(minLength: 0)
            Divider()
            footerBar
        }
        .frame(minWidth: 680, minHeight: 460)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            selectedSnapshotIds = Set(documentManager.pendingRecoverySnapshots.map { $0.id })
            previewedSnapshot = documentManager.pendingRecoverySnapshots.first
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.counterclockwise.circle")
                .foregroundColor(.blue)
                .font(.system(size: 16, weight: .semibold))

            Text(loc("crash_recovery_title"))
                .font(.system(size: 14, weight: .bold))

            Spacer()

            ModalCloseButton {
                documentManager.isCrashRecoveryPresented = false
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Info Banner

    private var infoBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .foregroundColor(.orange)
                .font(.system(size: 24))

            VStack(alignment: .leading, spacing: 2) {
                Text(loc("crash_recovery_subtitle"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(NSColor.labelColor))

                Text(loc("crash_recovery_info"))
                    .font(.system(size: 11))
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
            }
            Spacer()
        }
        .padding(10)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    // MARK: - Snapshot List

    private var snapshotListSection: some View {
        ScrollView {
            VStack(spacing: 6) {
                ForEach(documentManager.pendingRecoverySnapshots) { snapshot in
                    snapshotRow(for: snapshot)
                }
            }
        }
        .frame(maxHeight: 180)
    }

    private func snapshotRow(for snapshot: RecoverySnapshot) -> some View {
        let isSelected = selectedSnapshotIds.contains(snapshot.id)
        let isCurrentPreview = previewedSnapshot?.id == snapshot.id

        return HStack(spacing: 10) {
            Toggle("", isOn: Binding(
                get: { isSelected },
                set: { checked in
                    if checked {
                        selectedSnapshotIds.insert(snapshot.id)
                    } else {
                        selectedSnapshotIds.remove(snapshot.id)
                    }
                }
            ))
            .toggleStyle(.checkbox)
            .labelsHidden()

            Image(systemName: snapshot.isUntitled ? "doc.badge.ellipsis" : "doc.text")
                .font(.system(size: 14))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(snapshot.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(NSColor.labelColor))

                    Text(loc("recovered_badge"))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(Capsule())
                }

                Text(snapshot.originalPath ?? loc("untitled_document"))
                    .font(.system(size: 10))
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedDate(snapshot.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(Color(NSColor.secondaryLabelColor))

                Text("\(snapshot.content.count) bytes • \(snapshot.content.components(separatedBy: "\n").count) lines")
                    .font(.system(size: 9))
                    .foregroundColor(Color(NSColor.tertiaryLabelColor))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isCurrentPreview ? Color.blue.opacity(0.12) : Color(NSColor.controlBackgroundColor).opacity(0.4))
        )
        .contentShape(Rectangle())
        .onTapGesture {
            previewedSnapshot = snapshot
        }
    }

    // MARK: - Preview Section

    private func previewSection(for snapshot: RecoverySnapshot) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Content Preview — \(snapshot.title)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("SHA-256 Verified")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.green)
            }

            ScrollView {
                Text(snapshot.content.prefix(2000))
                    .font(.system(size: 11, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            }
            .frame(height: 110)
            .background(Color(NSColor.textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - Footer Bar

    private var footerBar: some View {
        HStack(spacing: 12) {
            Button(loc("discard_all")) {
                documentManager.discardAllRecoverySnapshots()
            }
            .buttonStyle(SecondaryButtonStyle())
            .font(.system(size: 12))

            if !selectedSnapshotIds.isEmpty && selectedSnapshotIds.count < documentManager.pendingRecoverySnapshots.count {
                Button(loc("discard_selected")) {
                    let targets = documentManager.pendingRecoverySnapshots.filter { selectedSnapshotIds.contains($0.id) }
                    documentManager.discardRecoverySnapshots(targets)
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.system(size: 12))
            }

            Spacer()

            if selectedSnapshotIds.count < documentManager.pendingRecoverySnapshots.count && !selectedSnapshotIds.isEmpty {
                Button(loc("recover_selected")) {
                    let targets = documentManager.pendingRecoverySnapshots.filter { selectedSnapshotIds.contains($0.id) }
                    documentManager.recoverSnapshots(targets)
                }
                .buttonStyle(ProminentButtonStyle())
                .font(.system(size: 12, weight: .semibold))
            }

            Button(loc("recover_all")) {
                documentManager.recoverSnapshots(documentManager.pendingRecoverySnapshots)
            }
            .buttonStyle(ProminentButtonStyle())
            .font(.system(size: 12, weight: .semibold))
            .keyboardShortcut(.defaultAction)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}
