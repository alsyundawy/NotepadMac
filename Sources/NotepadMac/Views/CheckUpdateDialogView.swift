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

public struct CheckUpdateDialogView: View {
    @ObservedObject var documentManager: DocumentManager
    @State private var isChecking: Bool = true
    @State private var statusMessage: String = loc("checking_for_updates")
    @State private var latestVersion: String?
    @State private var releaseNotes: String?
    @State private var releaseUrl: String = "https://github.com/alsyundawy/NotepadMac/releases"

    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider().background(Color.white.opacity(0.12))
            contentSection
            Divider().background(Color.white.opacity(0.12))
            footerSection
        }
        .frame(width: 480, height: 320)
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onAppear {
            checkForUpdates()
        }
    }

    private var headerBar: some View {
        HStack {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.blue)

            Text(loc("update_check_title"))
                .font(.system(size: 14, weight: .bold))

            Spacer()

            Button(action: {
                documentManager.isCheckUpdatePresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 15))
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut(.cancelAction)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var contentSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 54, height: 54)
                    .shadow(radius: 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("NotepadMac")
                        .font(.system(size: 18, weight: .bold))

                    Text("\(loc("current_version")): 1.0.0 (Build 2026.11)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)

                    if let latest = latestVersion {
                        Text("Latest Version: \(latest)")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            VStack(spacing: 10) {
                if isChecking {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.green)
                }

                Text(statusMessage)
                    .font(.system(size: 13, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(NSColor.labelColor))
                    .padding(.horizontal, 20)
            }
            .frame(maxHeight: .infinity)

            Spacer()
        }
    }

    private var footerSection: some View {
        HStack {
            Button(loc("visit_releases")) {
                if let url = URL(string: releaseUrl) {
                    NSWorkspace.shared.open(url)
                }
            }
            .font(.system(size: 12))

            Spacer()

            Button(loc("check_again")) {
                checkForUpdates()
            }
            .disabled(isChecking)
            .font(.system(size: 12))

            Button(loc("close")) {
                documentManager.isCheckUpdatePresented = false
            }
            .buttonStyle(ProminentButtonStyle())
            .font(.system(size: 12))
            .keyboardShortcut(.defaultAction)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private func checkForUpdates() {
        isChecking = true
        statusMessage = loc("checking_for_updates")
        latestVersion = nil

        guard let url = URL(string: "https://api.github.com/repos/alsyundawy/NotepadMac/releases/latest") else {
            finishChecking(status: loc("up_to_date"), version: "v1.0.0")
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0
        request.setValue("NotepadMac-App", forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: request) { data, response, _ in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                      let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    // Safe fallback if offline or API limit reached
                    self.finishChecking(status: loc("up_to_date"), version: "v1.0.0")
                    return
                }

                let tag = json["tag_name"] as? String ?? "v1.0.0"
                let htmlUrl = json["html_url"] as? String ?? "https://github.com/alsyundawy/NotepadMac/releases"
                self.releaseUrl = htmlUrl

                if tag == "v1.0.0" || tag == "1.0.0" {
                    self.finishChecking(status: loc("up_to_date"), version: tag)
                } else {
                    self.finishChecking(
                        status: "New release \(tag) is available on GitHub!",
                        version: tag
                    )
                }
            }
        }.resume()
    }

    private func finishChecking(status: String, version: String) {
        self.isChecking = false
        self.statusMessage = status
        self.latestVersion = version
    }
}
