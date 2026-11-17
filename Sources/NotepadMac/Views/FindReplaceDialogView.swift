//
//  FindReplaceDialogView.swift
//  NotepadMac
//
//  Dedicated SparkNotePad / Notepad++ style Find & Replace dialog window
//

import SwiftUI
import AppKit

public struct FindReplaceDialogView: View {
    @ObservedObject var documentManager: DocumentManager

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    public var body: some View {
        VStack(spacing: 0) {
            tabPickerHeader
            Divider()
            dialogMainBody
            Divider()
            statusFooter
        }
        .frame(width: 520, height: 320)
        .background(Color(NSColor.windowBackgroundColor))
        .foregroundColor(Color(NSColor.labelColor))
        .onReceive(NotificationCenter.default.publisher(for: .notepadSearchStatusUpdate)) { notif in
            if let status = notif.userInfo?["status"] as? String {
                documentManager.searchStatus = status
            }
        }
    }

    // MARK: - Tab Picker Header

    private var tabPickerHeader: some View {
        HStack {
            Picker("", selection: $documentManager.findDialogTab) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Find")
                }.tag(0)
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Replace")
                }.tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 230)

            Spacer()

            Button(
                action: { documentManager.isFindReplaceDialogPresented = false },
                label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                        .font(.system(size: 14))
                }
            )
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut(.cancelAction)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
    }

    // MARK: - Main Body

    private var dialogMainBody: some View {
        HStack(alignment: .top, spacing: 14) {
            inputAndOptionsColumn
            Divider().padding(.vertical, 8)
            actionButtonsColumn
        }
        .padding(16)
    }

    private var inputAndOptionsColumn: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Find input
            VStack(alignment: .leading, spacing: 4) {
                Text("Find what:")
                    .font(.system(size: 11, weight: .semibold))
                HStack(spacing: 4) {
                    TextField("Enter search term...", text: $documentManager.searchQuery, onCommit: {
                        triggerFindNext()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 12))

                    if !documentManager.searchQuery.isEmpty {
                        Button(action: { documentManager.searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }

            // Replace input (visible in Replace tab)
            if documentManager.findDialogTab == 1 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Replace with:")
                        .font(.system(size: 11, weight: .semibold))
                    HStack(spacing: 4) {
                        TextField(
                            "Enter replacement text...",
                            text: $documentManager.replaceQuery,
                            onCommit: { triggerReplaceNext() }
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 12))

                        if !documentManager.replaceQuery.isEmpty {
                            Button(action: { documentManager.replaceQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }

            // Search options checkboxes
            VStack(alignment: .leading, spacing: 6) {
                Text("Options")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(NSColor.secondaryLabelColor))

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle("Match case", isOn: $documentManager.isMatchCase)
                            .font(.system(size: 11))
                        Toggle("Whole word only", isOn: $documentManager.isWholeWord)
                            .font(.system(size: 11))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Toggle("Regular expression", isOn: $documentManager.isRegex)
                            .font(.system(size: 11))
                        Toggle("Wrap around", isOn: $documentManager.isWrapAround)
                            .font(.system(size: 11))
                    }
                }
            }

            // Direction selector
            HStack(spacing: 12) {
                Text("Direction:")
                    .font(.system(size: 11, weight: .semibold))
                Picker("", selection: $documentManager.searchDirectionUp) {
                    Text("Down").tag(false)
                    Text("Up").tag(true)
                }
                .pickerStyle(RadioGroupPickerStyle())
                .horizontalRadioGroupLayout()
                .font(.system(size: 11))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButtonsColumn: some View {
        VStack(spacing: 8) {
            Button(action: { triggerFindNext() }) {
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                    Text("Find Next")
                }
            }
            .buttonStyle(ProminentButtonStyle())
            .keyboardShortcut(.defaultAction)
            .frame(width: 105)

            Button(action: { triggerFindPrevious() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.up")
                    Text("Find Prev")
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            .frame(width: 105)

            if documentManager.findDialogTab == 1 {
                Button(action: { triggerReplaceNext() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Replace")
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
                .frame(width: 105)

                Button(action: { triggerReplaceAll() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        Text("Replace All")
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
                .frame(width: 105)
            }

            Button("Count") {
                triggerCount()
            }
            .buttonStyle(SecondaryButtonStyle())
            .frame(width: 105)

            Spacer()

            Button("Close") {
                documentManager.isFindReplaceDialogPresented = false
            }
            .buttonStyle(SecondaryButtonStyle())
            .frame(width: 105)
        }
        .font(.system(size: 11))
    }

    // MARK: - Status Footer

    private var statusFooter: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(.secondary)
                .font(.system(size: 10))

            Text(documentManager.searchStatus.isEmpty ? "Ready" : documentManager.searchStatus)
                .font(.system(size: 11))
                .foregroundColor(
                    documentManager.searchStatus.contains("Not found") ||
                    documentManager.searchStatus.contains("No match")
                        ? Color.red
                        : Color(NSColor.secondaryLabelColor)
                )

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
    }

    // MARK: - Search Actions

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
