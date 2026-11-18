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

public struct JwtInfo {
    public let headerJson: String
    public let payloadJson: String
    public let signature: String
    public let expirationDate: Date?
    public let issuedAtDate: Date?

    public init(
        headerJson: String,
        payloadJson: String,
        signature: String,
        expirationDate: Date? = nil,
        issuedAtDate: Date? = nil
    ) {
        self.headerJson = headerJson
        self.payloadJson = payloadJson
        self.signature = signature
        self.expirationDate = expirationDate
        self.issuedAtDate = issuedAtDate
    }
}

public enum DeveloperTools {

    // MARK: - JSON Prettify & Minify

    public static func formatJson(_ rawJson: String, indentSpaces: Int = 2) -> (result: String, error: String?) {
        guard let data = rawJson.data(using: .utf8) else {
            return ("", "Invalid UTF-8 string")
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let prettyData = try JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            )
            guard var prettyString = String(data: prettyData, encoding: .utf8) else {
                return ("", "Failed to decode pretty JSON data")
            }

            if indentSpaces != 2 {
                // Adjust indentation if custom spacing is requested
                let spaceStr = String(repeating: " ", count: indentSpaces)
                let lines = prettyString.components(separatedBy: "\n")
                let reformatted = lines.map { line -> String in
                    let leadingSpaces = line.prefix(while: { $0 == " " }).count
                    let depth = leadingSpaces / 2
                    let trimmed = line.dropFirst(leadingSpaces)
                    return String(repeating: spaceStr, count: depth) + trimmed
                }.joined(separator: "\n")
                prettyString = reformatted
            }

            return (prettyString, nil)
        } catch {
            return ("", "JSON Parsing Error: \(error.localizedDescription)")
        }
    }

    public static func minifyJson(_ rawJson: String) -> (result: String, error: String?) {
        guard let data = rawJson.data(using: .utf8) else {
            return ("", "Invalid UTF-8 string")
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let minifiedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.withoutEscapingSlashes])
            guard let minifiedString = String(data: minifiedData, encoding: .utf8) else {
                return ("", "Failed to encode minified JSON")
            }
            return (minifiedString, nil)
        } catch {
            return ("", "JSON Minify Error: \(error.localizedDescription)")
        }
    }

    // MARK: - XML Format & Minify

    public static func formatXml(_ rawXml: String) -> (result: String, error: String?) {
        let trimmed = rawXml.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", "Empty XML input") }

        do {
            let doc = try XMLDocument(xmlString: trimmed, options: [.nodePreserveWhitespace, .nodeCompactEmptyElement])
            let formatted = doc.xmlString(options: [.nodePrettyPrint])
            return (formatted, nil)
        } catch {
            return ("", "XML Format Error: \(error.localizedDescription)")
        }
    }

    public static func minifyXml(_ rawXml: String) -> (result: String, error: String?) {
        let trimmed = rawXml.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", "Empty XML input") }

        do {
            let doc = try XMLDocument(xmlString: trimmed, options: [.nodeCompactEmptyElement])
            let minified = doc.xmlString(options: [])
            // Strip inter-tag whitespaces
            let regex = try NSRegularExpression(pattern: ">\\s+<", options: [])
            let range = NSRange(location: 0, length: minified.utf16.count)
            let result = regex.stringByReplacingMatches(in: minified, options: [], range: range, withTemplate: "><")
            return (result, nil)
        } catch {
            return ("", "XML Minify Error: \(error.localizedDescription)")
        }
    }

    // MARK: - JWT Token Decoder

    public static func decodeJwt(_ token: String) -> (info: JwtInfo?, error: String?) {
        let parts = token.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ".")
        guard parts.count == 3 else {
            return (nil, "Invalid JWT: Token must have exactly 3 parts separated by dots")
        }

        let headerStr = MimeTools.base64Decode(parts[0])
        let payloadStr = MimeTools.base64Decode(parts[1])
        let signature = parts[2]

        let formattedHeader = formatJson(headerStr).result
        let formattedPayload = formatJson(payloadStr).result

        var expDate: Date?
        var iatDate: Date?

        if let data = payloadStr.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let exp = json["exp"] as? TimeInterval {
                expDate = Date(timeIntervalSince1970: exp)
            }
            if let iat = json["iat"] as? TimeInterval {
                iatDate = Date(timeIntervalSince1970: iat)
            }
        }

        let info = JwtInfo(
            headerJson: formattedHeader.isEmpty ? headerStr : formattedHeader,
            payloadJson: formattedPayload.isEmpty ? payloadStr : formattedPayload,
            signature: signature,
            expirationDate: expDate,
            issuedAtDate: iatDate
        )
        return (info, nil)
    }

    // MARK: - UUID v4 Generator

    public static func generateUuid(
        uppercase: Bool = false,
        braces: Bool = false,
        hyphens: Bool = true
    ) -> String {
        var uuid = UUID().uuidString
        if !hyphens {
            uuid = uuid.replacingOccurrences(of: "-", with: "")
        }
        if !uppercase {
            uuid = uuid.lowercased()
        }
        if braces {
            uuid = "{\(uuid)}"
        }
        return uuid
    }

    // MARK: - Unix Timestamp / Epoch Converter

    public static func epochToIso(_ epochSeconds: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epochSeconds))
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }

    public static func isoToEpoch(_ isoString: String) -> Int64? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: isoString) {
            return Int64(date.timeIntervalSince1970)
        }
        // Fallback without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: isoString) {
            return Int64(date.timeIntervalSince1970)
        }
        return nil
    }
}
