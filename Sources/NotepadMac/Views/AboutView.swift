//
//  AboutView.swift
//  NotepadMac
//
//  Modern, professional About, Credits, and GPLv3 Licensing panel
//

import SwiftUI
import AppKit

public struct AboutView: View {
    @ObservedObject var documentManager: DocumentManager
    @State private var selectedTab: Int = 0

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerSection
            Divider()
            tabPickerSection
            Divider()
            selectedTabContent
            Divider()
            footerSection
        }
        .frame(width: 540, height: 480)
        .background(Color(NSColor.windowBackgroundColor))
        .foregroundColor(Color(NSColor.labelColor))
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 16) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 3) {
                Text("NotepadMac")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(NSColor.labelColor))

                Text("Version 1.0.0 (Build 2026.11) • GPLv3")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(NSColor.secondaryLabelColor))

                Text("Universal Mach-O (Apple Silicon arm64 & Intel x86_64)")
                    .font(.system(size: 10))
                    .foregroundColor(Color.accentColor)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
    }

    // MARK: - Tab Picker

    private var tabPickerSection: some View {
        HStack {
            Picker("", selection: $selectedTab) {
                Text("About").tag(0)
                Text("Credits & Sources").tag(1)
                Text("GPLv3 License").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: 360)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.4))
    }

    // MARK: - Content Selector

    @ViewBuilder
    private var selectedTabContent: some View {
        switch selectedTab {
        case 0:
            aboutTabContent
        case 1:
            creditsTabContent
        case 2:
            licenseTabContent
        default:
            aboutTabContent
        }
    }

    // MARK: - Tab 1: About

    private var aboutTabContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Architecture & Components")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(NSColor.labelColor))

                VStack(spacing: 8) {
                    EngineInfoRow(
                        title: "Scintilla Cocoa",
                        version: "v5.6.9",
                        detail: "Native C++17 editing engine, line layout & styling"
                    )
                    EngineInfoRow(
                        title: "Lexilla Lexers",
                        version: "v5.5.5",
                        detail: "50+ syntax highlighters with hierarchical code folding"
                    )
                    EngineInfoRow(
                        title: "Embedded Lua",
                        version: "v5.5.1",
                        detail: "High-performance editor scripting & macro automation"
                    )
                    EngineInfoRow(
                        title: "Native Chrome",
                        version: "SwiftUI + AppKit",
                        detail: "Pure macOS cocoa application with zero Electron overhead"
                    )
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                )

                Text("Key Highlights")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(NSColor.labelColor))

                VStack(alignment: .leading, spacing: 4) {
                    FeatureCheckRow(text: "50+ Lexilla programming language lexers with folding")
                    FeatureCheckRow(text: "Dedicated SparkNotePad-style Find & Replace dialog")
                    FeatureCheckRow(text: "7 handcrafted developer color themes with dark/light auto-sync")
                    FeatureCheckRow(text: "Native Format menu with uppercase, lowercase, capitalize, invert")
                    FeatureCheckRow(text: "Multi-tab document manager with dirty tracking and colors")
                }
            }
            .padding(18)
        }
    }

    // MARK: - Tab 2: Credits & Sources

    private var creditsTabContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Third-Party Open Source Components")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(NSColor.labelColor))

                Text(
                    "NotepadMac integrates and links against the following open source " +
                    "works in strict compliance with their respective permissive licenses:"
                )
                .font(.system(size: 11))
                .foregroundColor(Color(NSColor.secondaryLabelColor))

                CreditBlockView(
                    name: "Scintilla (v5.6.9) & Lexilla (v5.5.5)",
                    author: "Neil Hodgson & Contributors <neilh@scintilla.org>",
                    licenseName: "HPND (Historical Permission Notice and Disclaimer)",
                    description: (
                        "Provides the native C++17 document buffer, styling, " +
                        "bidi layout, margin rendering, and 50+ language lexers."
                    )
                )

                CreditBlockView(
                    name: "Lua Programming Language (v5.5.1)",
                    author: "Roberto Ierusalimschy, Waldemar Celes, Luiz Henrique de Figueiredo (PUC-Rio)",
                    licenseName: "MIT License",
                    description: (
                        "Provides the embedded scripting engine for macros, " +
                        "automation, and editor state manipulation via CLua bridge."
                    )
                )

                CreditBlockView(
                    name: "SparkNotePad & TextEdit",
                    author: "SparkNotePad & Apple Inc.",
                    licenseName: "Design & UX Inspiration",
                    description: (
                        "Inspired the native macOS menu hierarchies, keyboard " +
                        "shortcuts, and the dedicated Find & Replace dialog."
                    )
                )
            }
            .padding(18)
        }
    }

    // MARK: - Tab 3: GPLv3 License

    private var licenseTabContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                    Text("GNU General Public License v3.0 (GPLv3)")
                        .font(.system(size: 12, weight: .bold))
                }

                Text(
                    "NotepadMac is free software: you can redistribute it and/or " +
                    "modify it under the terms of the GNU General Public License as " +
                    "published by the Free Software Foundation, either version 3 of the " +
                    "License, or (at your option) any later version."
                )
                .font(.system(size: 11))
                .foregroundColor(Color(NSColor.secondaryLabelColor))

                Text(
                    "This program is distributed in the hope that it will be useful, " +
                    "but WITHOUT ANY WARRANTY; without even the implied warranty of " +
                    "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the " +
                    "GNU General Public License for more details."
                )
                .font(.system(size: 10, design: .monospaced))
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
                .cornerRadius(6)

                Text("License Compatibility Notice")
                    .font(.system(size: 11, weight: .bold))

                Text(
                    "Scintilla/Lexilla (HPND) and Lua (MIT) are permissive open source " +
                    "licenses fully compatible with GPLv3. Linking against these libraries " +
                    "preserves original author copyrights and attribution without conflict."
                )
                .font(.system(size: 10))
                .foregroundColor(Color(NSColor.secondaryLabelColor))
            }
            .padding(18)
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            Button(
                action: {
                    if let url = URL(string: "https://github.com/alsyundawy/NotepadMac") {
                        NSWorkspace.shared.open(url)
                    }
                },
                label: {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.system(size: 10))
                        Text("GitHub Repository")
                            .font(.system(size: 11))
                    }
                }
            )
            .buttonStyle(SecondaryButtonStyle())

            Spacer()

            Button("Done") {
                documentManager.isAboutPresented = false
            }
            .buttonStyle(ProminentButtonStyle())
            .font(.system(size: 11))
            .keyboardShortcut(.defaultAction)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
    }
}

// MARK: - Helper Views

struct EngineInfoRow: View {
    let title: String
    let version: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(NSColor.labelColor))
                    Text(version)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(3)
                }
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
            }
            Spacer()
        }
    }
}

struct CreditBlockView: View {
    let name: String
    let author: String
    let licenseName: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.system(size: 11, weight: .bold))
                Spacer()
                Text(licenseName)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .cornerRadius(3)
            }
            Text(author)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(NSColor.secondaryLabelColor))
            Text(description)
                .font(.system(size: 10))
                .foregroundColor(Color(NSColor.secondaryLabelColor))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
}

struct FeatureCheckRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 10))
                .foregroundColor(.green)
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(Color(NSColor.secondaryLabelColor))
        }
    }
}
