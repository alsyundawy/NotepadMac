//
//  LuaConsoleSheet.swift
//  NotepadMac
//
//  Interactive Lua 5.5.1 scripting console and macro runner
//

import SwiftUI

public struct LuaConsoleSheet: View {
    @ObservedObject var documentManager: DocumentManager
    @State private var scriptText: String = """
-- NotepadMac Lua Automation Script
print("Hello from Lua 5.5.1!")
print("Current document line count: " .. editor.getLineCount())
print("Current cursor line: " .. editor.getCurrentLine())
"""
    @State private var consoleOutput: String = ""
    @State private var isRunning: Bool = false
    @State private var selectedSample: String = "Default"

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "terminal.fill")
                        .foregroundColor(.blue)
                    Text("Lua Scripting Console (Lua 5.5.1)")
                        .font(.system(size: 13, weight: .bold))
                }

                Spacer()

                // Sample scripts menu
                Menu("Sample Scripts") {
                    Button("Document Statistics") {
                        scriptText = """
local count = editor.getLineCount()
local text = editor.getText()
local bytes = string.len(text)
print("=== Document Statistics ===")
print("Total lines: " .. count)
print("Total characters (bytes): " .. bytes)
print("Current line: " .. editor.getCurrentLine())
"""
                    }

                    Button("Prepend Timestamp Header") {
                        scriptText = """
local dateStr = os.date("%Y-%m-%d %H:%M:%S")
local header = "# Document Header - " .. dateStr .. "\\n\\n"
editor.insertText(0, header)
print("Header inserted successfully.")
"""
                    }

                    Button("Uppercase Document") {
                        scriptText = """
local text = editor.getText()
editor.setText(string.upper(text))
print("Converted all text to UPPERCASE.")
"""
                    }

                    Button("Lowercase Document") {
                        scriptText = """
local text = editor.getText()
editor.setText(string.lower(text))
print("Converted all text to lowercase.")
"""
                    }

                    Button("Clear Document") {
                        scriptText = """
editor.clear()
print("Document cleared.")
"""
                    }
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .font(.system(size: 11))

                Button("Close") {
                    documentManager.isLuaConsolePresented = false
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.system(size: 11))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(red: 0.14, green: 0.15, blue: 0.17))

            Divider()

            // Script Input & Output Split
            HSplitView {
                // Left: Script Editor
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Script Editor")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("editor.* API available")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 8)

                    TextEditor(text: $scriptText)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(6)
                        .background(Color(white: 0.12))
                        .cornerRadius(6)
                        .padding(.horizontal, 8)

                    HStack {
                        Button(action: runScript) {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                Text("Run Script")
                            }
                            .font(.system(size: 11, weight: .semibold))
                        }
                        .buttonStyle(ProminentButtonStyle())
                        .keyboardShortcut(.return, modifiers: [.command])

                        Spacer()

                        Button("Reset Engine") {
                            documentManager.luaEngine.reset()
                            consoleOutput += "\n[Lua state re-initialized]\n"
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .font(.system(size: 11))
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                }
                .frame(minWidth: 320)

                // Right: Console Output Log
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Execution Log / Output")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Clear Output") {
                            consoleOutput = ""
                        }
                        .buttonStyle(PlainButtonStyle())
                        .font(.system(size: 10))
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 8)

                    ScrollView {
                        Text(consoleOutput.isEmpty ? "Ready. Click 'Run Script' to execute." : consoleOutput)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(consoleOutput.contains("[Error]") ? .red : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                    }
                    .background(Color(white: 0.10))
                    .cornerRadius(6)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
                .frame(minWidth: 280)
            }
        }
        .frame(minWidth: 640, minHeight: 400)
        .background(Color(red: 0.16, green: 0.18, blue: 0.20))
    }

    private func runScript() {
        isRunning = true
        let result = documentManager.luaEngine.execute(script: scriptText, delegate: documentManager)
        isRunning = false

        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        var newLog = "[\(timestamp)] "

        if result.success {
            newLog += "Success\n"
            if !result.output.isEmpty {
                newLog += result.output + "\n"
            }
        } else {
            newLog += "[Error] " + (result.error ?? "Script failed") + "\n"
            if !result.output.isEmpty {
                newLog += "Partial output:\n" + result.output + "\n"
            }
        }

        consoleOutput += newLog + "\n"
    }
}
