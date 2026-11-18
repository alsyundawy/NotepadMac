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

public enum HashAlgorithm: String, CaseIterable, Identifiable {
    case md5 = "MD5"
    case sha1 = "SHA-1"
    case sha256 = "SHA-256"
    case sha384 = "SHA-384"
    case sha512 = "SHA-512"
    case crc32 = "CRC32"

    public var id: String { rawValue }
}

public enum HashTools {
    public static func computeHash(_ text: String, algorithm: HashAlgorithm) -> String {
        guard let data = text.data(using: .utf8) else {
            return ""
        }
        return computeHash(data, algorithm: algorithm)
    }

    public static func computeFileHash(at url: URL, algorithm: HashAlgorithm) throws -> String {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        return computeHash(data, algorithm: algorithm)
    }

    public static func computeHash(_ data: Data, algorithm: HashAlgorithm) -> String {
        switch algorithm {
        case .md5:
            let digest = Insecure.MD5.hash(data: data)
            return digest.map { String(format: "%02x", $0) }.joined()
        case .sha1:
            let digest = Insecure.SHA1.hash(data: data)
            return digest.map { String(format: "%02x", $0) }.joined()
        case .sha256:
            let digest = SHA256.hash(data: data)
            return digest.map { String(format: "%02x", $0) }.joined()
        case .sha384:
            let digest = SHA384.hash(data: data)
            return digest.map { String(format: "%02x", $0) }.joined()
        case .sha512:
            let digest = SHA512.hash(data: data)
            return digest.map { String(format: "%02x", $0) }.joined()
        case .crc32:
            let crc = computeCRC32(data: data)
            return String(format: "%08X", crc)
        }
    }

    // Standard IEEE 802.3 CRC32 calculation table
    private static let crc32Table: [UInt32] = {
        (0..<256).map { i -> UInt32 in
            var c = UInt32(i)
            for _ in 0..<8 {
                if (c & 1) != 0 {
                    c = 0xEDB88320 ^ (c >> 1)
                } else {
                    c = c >> 1
                }
            }
            return c
        }
    }()

    public static func computeCRC32(data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFFFFFF
        for byte in data {
            let index = Int((crc ^ UInt32(byte)) & 0xFF)
            crc = (crc >> 8) ^ crc32Table[index]
        }
        return crc ^ 0xFFFFFFFF
    }
}
