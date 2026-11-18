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

public enum MimeTools {

    // MARK: - Base64

    public static func base64Encode(_ text: String, withPadding: Bool = true) -> String {
        guard let data = text.data(using: .utf8) else { return "" }
        var encoded = data.base64EncodedString()
        if !withPadding {
            encoded = encoded.replacingOccurrences(of: "=", with: "")
        }
        return encoded
    }

    public static func base64EncodeByLine(_ text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        return lines.map { base64Encode($0) }.joined(separator: "\n")
    }

    public static func base64Decode(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var sanitized = trimmed
        // Add missing padding if needed
        let mod = sanitized.count % 4
        if mod != 0 {
            sanitized += String(repeating: "=", count: 4 - mod)
        }
        guard let data = Data(base64Encoded: sanitized) else {
            return "Error: Invalid Base64 data"
        }
        return String(data: data, encoding: .utf8) ?? "Error: Unable to decode UTF-8 string"
    }

    public static func base64DecodeByLine(_ text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        return lines.map { base64Decode($0) }.joined(separator: "\n")
    }

    // MARK: - URL Encode / Decode (RFC 3986)

    public static func urlEncode(_ text: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return text.addingPercentEncoding(withAllowedCharacters: allowed) ?? text
    }

    public static func urlDecode(_ text: String) -> String {
        let plusReplaced = text.replacingOccurrences(of: "+", with: " ")
        return plusReplaced.removingPercentEncoding ?? text
    }

    // MARK: - HTML Entity Encode / Decode

    public static func htmlEntityEncode(_ text: String) -> String {
        var result = ""
        for char in text {
            switch char {
            case "&": result.append("&amp;")
            case "<": result.append("&lt;")
            case ">": result.append("&gt;")
            case "\"": result.append("&quot;")
            case "'": result.append("&#39;")
            default: result.append(char)
            }
        }
        return result
    }

    public static func htmlEntityDecode(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
    }

    // MARK: - Quoted-Printable Encode / Decode

    public static func quotedPrintableEncode(_ text: String) -> String {
        guard let data = text.data(using: .utf8) else { return text }
        var result = ""
        var lineLength = 0

        for byte in data {
            // Printable ASCII except '='
            if (byte >= 33 && byte <= 60) || (byte >= 62 && byte <= 126) || byte == 32 || byte == 9 {
                result.append(Character(UnicodeScalar(byte)))
                lineLength += 1
            } else if byte == 10 { // LF
                result.append("\n")
                lineLength = 0
                continue
            } else if byte == 13 { // CR
                continue
            } else {
                let hex = String(format: "=%02X", byte)
                result.append(hex)
                lineLength += 3
            }

            if lineLength >= 75 {
                result.append("=\n")
                lineLength = 0
            }
        }
        return result
    }

    public static func quotedPrintableDecode(_ text: String) -> String {
        var clean = text.replacingOccurrences(of: "=\r\n", with: "")
        clean = clean.replacingOccurrences(of: "=\n", with: "")

        var outputBytes = [UInt8]()
        var i = clean.startIndex

        while i < clean.endIndex {
            if clean[i] == "=" {
                let next1 = clean.index(after: i)
                if next1 < clean.endIndex {
                    let next2 = clean.index(after: next1)
                    if next2 < clean.endIndex {
                        let hexStr = String(clean[next1...next2])
                        if let byteVal = UInt8(hexStr, radix: 16) {
                            outputBytes.append(byteVal)
                            i = clean.index(after: next2)
                            continue
                        }
                    }
                }
            }

            let scalar = clean[i].unicodeScalars.first?.value ?? 0
            if scalar <= 255 {
                outputBytes.append(UInt8(scalar))
            } else {
                if let utf8Data = String(clean[i]).data(using: .utf8) {
                    outputBytes.append(contentsOf: utf8Data)
                }
            }
            i = clean.index(after: i)
        }

        return String(bytes: outputBytes, encoding: .utf8) ?? clean
    }
}
