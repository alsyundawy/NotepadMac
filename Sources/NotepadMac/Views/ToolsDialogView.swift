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

public struct ToolsDialogView: View {
    @ObservedObject var documentManager: DocumentManager
    @State private var selectedTab: Int = 0

    // Shared input/output state
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var statusNote: String = ""

    // Hash state
    @State private var selectedHashAlgo: HashAlgorithm = .sha256
    @State private var compareHashInput: String = ""
    @State private var hashMatchStatus: String?

    // MIME state
    @State private var isBase64Padding: Bool = true

    // Converter state
    @State private var converterSourceBase: NumberBase = .decimal
    @State private var converterTargetBase: NumberBase = .hexadecimal

    // Encryption state
    @State private var cryptoPassphrase: String = ""
    @State private var passwordStrength: PasswordStrength = PasswordStrength(score: 0, label: "Empty", isStrong: false)

    // Developer tools state
    @State private var jsonIndentSpaces: Int = 2
    @State private var uuidCount: Int = 1
    @State private var uuidUppercase: Bool = false
    @State private var uuidBraces: Bool = false
    @State private var uuidHyphens: Bool = true
    @State private var epochInput: String = "\(Int(Date().timeIntervalSince1970))"

    public init(documentManager: DocumentManager, initialTab: Int = 0) {
        self.documentManager = documentManager
        self._selectedTab = State(initialValue: initialTab)
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider().background(Color.white.opacity(0.12))
            tabSelector
            Divider().background(Color.white.opacity(0.12))
            tabContentSection
            Divider().background(Color.white.opacity(0.12))
            footerBar
        }
        .frame(width: 680, height: 530)
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onAppear {
            loadInitialText()
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Image(systemName: "wrench.and.screwdriver.fill")
                .foregroundColor(.blue)
                .font(.system(size: 15))

            Text(loc("tools_hub"))
                .font(.system(size: 14, weight: .bold))

            Spacer()

            Button(action: {
                documentManager.isToolsDialogPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut(.cancelAction)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        Picker("", selection: $selectedTab) {
            Text(loc("hash_tools")).tag(0)
            Text(loc("mime_tools")).tag(1)
            Text(loc("converter")).tag(2)
            Text(loc("encryption")).tag(3)
            Text(loc("developer_tools")).tag(4)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContentSection: some View {
        VStack(spacing: 12) {
            switch selectedTab {
            case 0: hashTab
            case 1: mimeTab
            case 2: converterTab
            case 3: cryptoTab
            default: devToolsTab
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Tab 0: Hash & Checksums

    private var hashTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(loc("hash_algorithm") + ":")
                    .font(.subheadline)

                Picker("", selection: $selectedHashAlgo) {
                    ForEach(HashAlgorithm.allCases) { algo in
                        Text(algo.rawValue).tag(algo)
                    }
                }
                .frame(width: 140)

                Spacer()

                Button(loc("generate_hash")) {
                    outputText = HashTools.computeHash(inputText, algorithm: selectedHashAlgo)
                    checkHashComparison()
                }
                .buttonStyle(ProminentButtonStyle())
            }

            inputEditorBox(placeholder: "Enter text to compute checksum...")

            outputDisplayBox(title: "Computed Digest (\(selectedHashAlgo.rawValue)):")

            HStack {
                Text("Verify Hash:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Paste expected hash to verify match...", text: $compareHashInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 11, design: .monospaced))
                    .onChange(of: compareHashInput) { _ in checkHashComparison() }

                if let match = hashMatchStatus {
                    Text(match)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(match.contains("MATCH") ? .green : .red)
                }
            }
        }
    }

    private func checkHashComparison() {
        guard !compareHashInput.isEmpty && !outputText.isEmpty else {
            hashMatchStatus = nil
            return
        }
        let cleanExpected = compareHashInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanOutput = outputText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if cleanExpected == cleanOutput {
            hashMatchStatus = "✓ MATCH"
        } else {
            hashMatchStatus = "✗ MISMATCH"
        }
    }

    // MARK: - Tab 1: MIME & Encoding

    private var mimeTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            inputEditorBox(placeholder: "Enter text to encode/decode...")

            HStack(spacing: 8) {
                Menu("Base64") {
                    Button(loc("base64_encode")) {
                        outputText = MimeTools.base64Encode(inputText, withPadding: isBase64Padding)
                    }
                    Button("Base64 Encode (By Line)") {
                        outputText = MimeTools.base64EncodeByLine(inputText)
                    }
                    Button(loc("base64_decode")) {
                        outputText = MimeTools.base64Decode(inputText)
                    }
                }

                Menu("URL (RFC 3986)") {
                    Button(loc("url_encode")) {
                        outputText = MimeTools.urlEncode(inputText)
                    }
                    Button(loc("url_decode")) {
                        outputText = MimeTools.urlDecode(inputText)
                    }
                }

                Menu("HTML Entity") {
                    Button(loc("html_entity_encode")) {
                        outputText = MimeTools.htmlEntityEncode(inputText)
                    }
                    Button(loc("html_entity_decode")) {
                        outputText = MimeTools.htmlEntityDecode(inputText)
                    }
                }

                Menu("Quoted-Printable") {
                    Button(loc("quoted_printable_encode")) {
                        outputText = MimeTools.quotedPrintableEncode(inputText)
                    }
                    Button(loc("quoted_printable_decode")) {
                        outputText = MimeTools.quotedPrintableDecode(inputText)
                    }
                }

                Spacer()
            }

            outputDisplayBox(title: "Result:")
        }
    }

    // MARK: - Tab 2: Converter

    private var converterTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            inputEditorBox(placeholder: "Enter value or text to convert...")

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Number Base Conversion:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        Picker("From:", selection: $converterSourceBase) {
                            ForEach(NumberBase.allCases) { base in
                                Text(base.rawValue).tag(base)
                            }
                        }
                        .frame(width: 140)

                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)

                        Picker("To:", selection: $converterTargetBase) {
                            ForEach(NumberBase.allCases) { base in
                                Text(base.rawValue).tag(base)
                            }
                        }
                        .frame(width: 140)

                        Button("Convert") {
                            outputText = ConverterTools.convertNumber(
                                inputText,
                                from: converterSourceBase,
                                to: converterTargetBase
                            )
                        }
                    }
                }

                Spacer()
            }

            HStack(spacing: 8) {
                Button(loc("ascii_to_hex")) {
                    outputText = ConverterTools.asciiToHex(inputText)
                }
                Button(loc("hex_to_ascii")) {
                    outputText = ConverterTools.hexToAscii(inputText)
                }
                Button(loc("sentence_case")) {
                    outputText = ConverterTools.toSentenceCase(inputText)
                }
                Button(loc("invert_case")) {
                    outputText = ConverterTools.toInvertCase(inputText)
                }
            }

            outputDisplayBox(title: "Converted Output:")
        }
    }

    // MARK: - Tab 3: Encryption (AES-256)

    private var cryptoTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SecureField("Enter secret passphrase...", text: $cryptoPassphrase)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: cryptoPassphrase) { val in
                        passwordStrength = CryptoTools.evaluatePasswordStrength(val)
                    }

                Text("Strength: \(passwordStrength.label)")
                    .font(.caption)
                    .foregroundColor(passwordStrength.isStrong ? .green : (passwordStrength.score >= 40 ? .orange : .red))

                Spacer()

                Button(loc("encrypt_aes")) {
                    let res = CryptoTools.encrypt(text: inputText, passphrase: cryptoPassphrase)
                    outputText = res.success ? res.data : (res.errorMessage ?? "Error")
                }
                .buttonStyle(ProminentButtonStyle())

                Button(loc("decrypt_aes")) {
                    let res = CryptoTools.decrypt(ciphertext: inputText, passphrase: cryptoPassphrase)
                    outputText = res.success ? res.data : (res.errorMessage ?? "Error")
                }
            }

            inputEditorBox(placeholder: "Enter plain text to encrypt OR ciphertext to decrypt...")

            outputDisplayBox(title: "Cryptographic Output:")
        }
    }

    // MARK: - Tab 4: Developer Tools

    private var devToolsTab: some View {
        VStack(alignment: .leading, spacing: 10) {
            inputEditorBox(placeholder: "Paste JSON, XML, or JWT token...")

            HStack(spacing: 8) {
                Menu("JSON") {
                    Button(loc("format_json")) {
                        let res = DeveloperTools.formatJson(inputText, indentSpaces: jsonIndentSpaces)
                        outputText = res.error ?? res.result
                    }
                    Button(loc("minify_json")) {
                        let res = DeveloperTools.minifyJson(inputText)
                        outputText = res.error ?? res.result
                    }
                }

                Menu("XML") {
                    Button(loc("format_xml")) {
                        let res = DeveloperTools.formatXml(inputText)
                        outputText = res.error ?? res.result
                    }
                    Button(loc("minify_xml")) {
                        let res = DeveloperTools.minifyXml(inputText)
                        outputText = res.error ?? res.result
                    }
                }

                Button(loc("jwt_decoder")) {
                    let res = DeveloperTools.decodeJwt(inputText)
                    if let err = res.error {
                        outputText = "JWT Error: \(err)"
                    } else if let info = res.info {
                        var out = "=== JWT HEADER ===\n\(info.headerJson)\n\n=== JWT PAYLOAD ===\n\(info.payloadJson)"
                        if let exp = info.expirationDate {
                            out += "\n\nExpiration: \(exp)"
                        }
                        outputText = out
                    }
                }

                Button(loc("generate_uuid")) {
                    outputText = DeveloperTools.generateUuid(
                        uppercase: uuidUppercase,
                        braces: uuidBraces,
                        hyphens: uuidHyphens
                    )
                }

                Button("Now Epoch") {
                    let epoch = Int64(Date().timeIntervalSince1970)
                    outputText = "Epoch: \(epoch)\nISO: \(DeveloperTools.epochToIso(epoch))"
                }

                Spacer()
            }

            outputDisplayBox(title: "Processed Output:")
        }
    }

    // MARK: - Reusable Input & Output Helpers

    private func inputEditorBox(placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Input:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("From Active Document") {
                    inputText = documentManager.activeDocument?.content ?? ""
                }
                .font(.caption)
            }

            TextEditor(text: $inputText)
                .font(.system(size: 11, design: .monospaced))
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        }
    }

    private func outputDisplayBox(title: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if !outputText.isEmpty {
                    Button(loc("copy")) {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(outputText, forType: .string)
                        statusNote = loc("copied")
                    }
                    .font(.caption)
                }
            }

            TextEditor(text: $outputText)
                .font(.system(size: 11, design: .monospaced))
                .frame(height: 110)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        }
    }

    // MARK: - Footer Bar

    private var footerBar: some View {
        HStack {
            if !statusNote.isEmpty {
                Text(statusNote)
                    .font(.caption)
                    .foregroundColor(.green)
            }

            Spacer()

            Button(loc("apply_to_active_doc")) {
                if !outputText.isEmpty, let doc = documentManager.activeDocument {
                    doc.content = outputText
                    doc.isModified = true
                    statusNote = "Applied to \(doc.title)"
                }
            }
            .disabled(outputText.isEmpty || documentManager.activeDocument == nil)
            .font(.system(size: 12))

            Button(loc("close")) {
                documentManager.isToolsDialogPresented = false
            }
            .buttonStyle(ProminentButtonStyle())
            .font(.system(size: 12))
            .keyboardShortcut(.defaultAction)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private func loadInitialText() {
        if let doc = documentManager.activeDocument {
            if doc.selectionLength > 0 {
                // If there is selection, use selection, else doc content
                inputText = doc.content
            } else {
                inputText = doc.content
            }
        }
    }
}
