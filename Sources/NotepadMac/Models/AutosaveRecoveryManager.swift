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

import Foundation
import CryptoKit

/// Represents a persistent snapshot of an unsaved or modified document
public struct RecoverySnapshot: Codable, Identifiable, Equatable {
    public let id: UUID
    public let documentId: UUID
    public let title: String
    public let originalPath: String?
    public let isUntitled: Bool
    public let content: String
    public let cursorLine: Int
    public let timestamp: Date
    public let checksum: String
    public let encodingName: String
    public let lineEndingRaw: String
    public let languageIdentifier: String

    public init(
        id: UUID = UUID(),
        documentId: UUID,
        title: String,
        originalPath: String?,
        isUntitled: Bool,
        content: String,
        cursorLine: Int = 1,
        timestamp: Date = Date(),
        checksum: String,
        encodingName: String = "utf-8",
        lineEndingRaw: String = "\n",
        languageIdentifier: String = "plaintext"
    ) {
        self.id = id
        self.documentId = documentId
        self.title = title
        self.originalPath = originalPath
        self.isUntitled = isUntitled
        self.content = content
        self.cursorLine = cursorLine
        self.timestamp = timestamp
        self.checksum = checksum
        self.encodingName = encodingName
        self.lineEndingRaw = lineEndingRaw
        self.languageIdentifier = languageIdentifier
    }
}

/// Manages periodic background document snapshots and post-incident crash recovery
public final class AutosaveRecoveryManager: ObservableObject {
    public static let defaultInterval: TimeInterval = 10.0 // 10 seconds

    public let recoveryDirectory: URL
    public private(set) var interval: TimeInterval
    private var timer: Timer?
    private var documentProvider: (() -> [EditorDocument])?
    private let fileManager = FileManager.default

    public static var defaultRecoveryDirectory: URL {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return appSupport.appendingPathComponent("NotepadMac/Recovery", isDirectory: true)
    }

    public init(
        recoveryDirectory: URL = AutosaveRecoveryManager.defaultRecoveryDirectory,
        interval: TimeInterval = AutosaveRecoveryManager.defaultInterval
    ) {
        self.recoveryDirectory = recoveryDirectory
        self.interval = interval
        ensureRecoveryDirectory()
    }

    deinit {
        stop()
    }

    // MARK: - Directory Management & POSIX 0700 / 0600 Permissions

    private func ensureRecoveryDirectory() {
        if !fileManager.fileExists(atPath: recoveryDirectory.path) {
            do {
                try fileManager.createDirectory(
                    at: recoveryDirectory,
                    withIntermediateDirectories: true,
                    attributes: [.posixPermissions: 0o700]
                )
            } catch {
                print("Failed to create recovery directory at \(recoveryDirectory.path): \(error)")
            }
        }
    }

    // MARK: - Timer Control

    public func start(documentProvider: @escaping () -> [EditorDocument]) {
        self.documentProvider = documentProvider
        stop()

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.performAutosaveSnapshotTick()
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Snapshot Operations

    /// Runs periodic snapshot tick, capturing modified documents
    public func performAutosaveSnapshotTick() {
        guard let documents = documentProvider?() else { return }
        saveSnapshots(for: documents)
    }

    /// Saves snapshot for modified documents and removes snapshots for clean documents
    public func saveSnapshots(for documents: [EditorDocument]) {
        ensureRecoveryDirectory()

        var activeModifiedDocIds = Set<UUID>()

        for doc in documents {
            if doc.isModified && !doc.content.isEmpty {
                activeModifiedDocIds.insert(doc.id)
                saveSnapshot(for: doc)
            } else if !doc.isModified {
                removeSnapshot(for: doc.id)
            }
        }
    }

    /// Writes an atomic snapshot with POSIX 0600 permissions and SHA-256 integrity validation
    @discardableResult
    public func saveSnapshot(for doc: EditorDocument) -> Bool {
        ensureRecoveryDirectory()

        let content = doc.content
        let checksum = Self.computeSHA256(content)
        let snapshot = RecoverySnapshot(
            documentId: doc.id,
            title: doc.title,
            originalPath: doc.fileURL?.path,
            isUntitled: doc.fileURL == nil,
            content: content,
            cursorLine: doc.cursorLine,
            timestamp: Date(),
            checksum: checksum,
            encodingName: doc.encoding == .utf8 ? "utf-8" : "other",
            lineEndingRaw: doc.lineEnding.separator,
            languageIdentifier: doc.language.id
        )

        let targetURL = recoveryDirectory.appendingPathComponent("\(doc.id.uuidString).snapshot.json")

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(snapshot)

            try data.write(to: targetURL, options: .atomic)
            // Enforce private 0600 permissions
            try fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: targetURL.path)
            return true
        } catch {
            print("Failed to write snapshot for \(doc.title): \(error.localizedDescription)")
            return false
        }
    }

    /// Removes snapshot for a specific document ID (e.g. after clean save or close)
    public func removeSnapshot(for documentId: UUID) {
        let targetURL = recoveryDirectory.appendingPathComponent("\(documentId.uuidString).snapshot.json")
        if fileManager.fileExists(atPath: targetURL.path) {
            try? fileManager.removeItem(at: targetURL)
        }
    }

    /// Removes all existing snapshots in the recovery directory
    public func clearAllSnapshots() {
        guard fileManager.fileExists(atPath: recoveryDirectory.path) else { return }
        if let files = try? fileManager.contentsOfDirectory(at: recoveryDirectory, includingPropertiesForKeys: nil) {
            for file in files where file.pathExtension == "json" {
                try? fileManager.removeItem(at: file)
            }
        }
    }

    // MARK: - Recovery Discovery & Validation

    /// Checks whether any recoverable snapshots exist on disk
    public func hasPendingSnapshots() -> Bool {
        return !loadPendingSnapshots().isEmpty
    }

    /// Loads and validates all recoverable snapshots from disk
    public func loadPendingSnapshots() -> [RecoverySnapshot] {
        guard fileManager.fileExists(atPath: recoveryDirectory.path) else { return [] }

        guard let files = try? fileManager.contentsOfDirectory(
            at: recoveryDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        ) else {
            return []
        }

        var results: [RecoverySnapshot] = []
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for file in files where file.lastPathComponent.hasSuffix(".snapshot.json") {
            do {
                let data = try Data(contentsOf: file)
                let snapshot = try decoder.decode(RecoverySnapshot.self, from: data)

                // Verify SHA-256 integrity check (guard against partially corrupted files)
                let calculatedChecksum = Self.computeSHA256(snapshot.content)
                if calculatedChecksum == snapshot.checksum {
                    results.append(snapshot)
                } else {
                    print("Corrupted recovery snapshot rejected (checksum mismatch): \(file.lastPathComponent)")
                }
            } catch {
                print("Failed to decode snapshot \(file.lastPathComponent): \(error)")
            }
        }

        return results.sorted(by: { $0.timestamp > $1.timestamp })
    }

    // MARK: - Integrity Checksum

    public static func computeSHA256(_ text: String) -> String {
        let inputData = Data(text.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
