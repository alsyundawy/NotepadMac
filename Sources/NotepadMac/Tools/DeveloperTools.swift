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

public enum HtmlEncryptMethod: String, CaseIterable, Identifiable {
    case javascriptEscape = "JS unescape"
    case base64 = "Base64 Obfuscation"
    case passwordProtected = "Password (AES-GCM)"

    public var id: String { rawValue }
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

    // MARK: - HTML Minify & Format

    public static func minifyHtml(_ rawHtml: String) -> (result: String, error: String?) {
        let trimmed = rawHtml.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", "Empty HTML input") }

        var output = trimmed
        if let regexComments = try? NSRegularExpression(pattern: "<!--(?!\\s*\\[if)[\\s\\S]*?-->", options: []) {
            let range = NSRange(output.startIndex..<output.endIndex, in: output)
            output = regexComments.stringByReplacingMatches(in: output, options: [], range: range, withTemplate: "")
        }

        if let regexSpaces = try? NSRegularExpression(pattern: ">\\s+<", options: []) {
            let range = NSRange(output.startIndex..<output.endIndex, in: output)
            output = regexSpaces.stringByReplacingMatches(in: output, options: [], range: range, withTemplate: "><")
        }

        if let regexMultiSpace = try? NSRegularExpression(pattern: "[\\t\\n\\r]+", options: []) {
            let range = NSRange(output.startIndex..<output.endIndex, in: output)
            output = regexMultiSpace.stringByReplacingMatches(in: output, options: [], range: range, withTemplate: " ")
        }

        return (output.trimmingCharacters(in: .whitespacesAndNewlines), nil)
    }

    public static func formatHtml(_ rawHtml: String, indentSpaces: Int = 2) -> (result: String, error: String?) {
        let trimmed = rawHtml.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", "Empty HTML input") }

        let indentUnit = String(repeating: " ", count: max(1, indentSpaces))
        let voidElements: Set<String> = [
            "area", "base", "br", "col", "embed", "hr", "img", "input",
            "link", "meta", "param", "source", "track", "wbr", "!doctype"
        ]

        var formattedLines: [String] = []
        var indentLevel = 0

        guard let tagRegex = try? NSRegularExpression(pattern: "(<[^>]+>)", options: []) else {
            return (trimmed, nil)
        }

        let nsString = trimmed as NSString
        let matches = tagRegex.matches(in: trimmed, options: [], range: NSRange(location: 0, length: nsString.length))

        var lastEnd = 0
        var tokens: [String] = []

        for match in matches {
            let matchRange = match.range
            if matchRange.location > lastEnd {
                let textBetween = nsString.substring(
                    with: NSRange(location: lastEnd, length: matchRange.location - lastEnd)
                )
                let cleanText = textBetween.trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleanText.isEmpty {
                    tokens.append(cleanText)
                }
            }
            tokens.append(nsString.substring(with: matchRange))
            lastEnd = matchRange.location + matchRange.length
        }

        if lastEnd < nsString.length {
            let trailing = nsString.substring(from: lastEnd).trimmingCharacters(in: .whitespacesAndNewlines)
            if !trailing.isEmpty {
                tokens.append(trailing)
            }
        }

        for token in tokens {
            if token.hasPrefix("<!") || token.hasPrefix("<?") {
                let indent = String(repeating: indentUnit, count: max(0, indentLevel))
                formattedLines.append(indent + token)
            } else if token.hasPrefix("</") {
                indentLevel = max(0, indentLevel - 1)
                let indent = String(repeating: indentUnit, count: max(0, indentLevel))
                formattedLines.append(indent + token)
            } else if token.hasPrefix("<") {
                let isSelfClosing = token.hasSuffix("/>")
                let tagScanner = Scanner(string: token)
                _ = tagScanner.scanString("<")
                let tagName = (tagScanner.scanCharacters(from: .alphanumerics) ?? "").lowercased()
                let isVoid = voidElements.contains(tagName) || isSelfClosing

                let indent = String(repeating: indentUnit, count: max(0, indentLevel))
                formattedLines.append(indent + token)

                if !isVoid {
                    indentLevel += 1
                }
            } else {
                let indent = String(repeating: indentUnit, count: max(0, indentLevel))
                formattedLines.append(indent + token)
            }
        }

        return (formattedLines.joined(separator: "\n"), nil)
    }

    // MARK: - CSS Minify & Format

    public static func minifyCss(_ rawCss: String) -> (result: String, error: String?) {
        let trimmed = rawCss.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", "Empty CSS input") }

        var output = trimmed
        if let regexComments = try? NSRegularExpression(pattern: "/\\*[\\s\\S]*?\\*/", options: []) {
            let range = NSRange(output.startIndex..<output.endIndex, in: output)
            output = regexComments.stringByReplacingMatches(in: output, options: [], range: range, withTemplate: "")
        }

        let replacements: [(String, String)] = [
            ("\\s*\\{\\s*", "{"),
            ("\\s*\\}\\s*", "}"),
            ("\\s*:\\s*", ":"),
            ("\\s*;\\s*", ";"),
            ("\\s*,\\s*", ","),
            (";\\}", "}"),
            ("\\s+", " ")
        ]

        for (pattern, repl) in replacements {
            if let rx = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(output.startIndex..<output.endIndex, in: output)
                output = rx.stringByReplacingMatches(in: output, options: [], range: range, withTemplate: repl)
            }
        }

        return (output.trimmingCharacters(in: .whitespacesAndNewlines), nil)
    }

    public static func formatCss(_ rawCss: String, indentSpaces: Int = 2) -> (result: String, error: String?) {
        let minified = minifyCss(rawCss).result
        guard !minified.isEmpty else { return ("", "Empty CSS input") }

        let indentUnit = String(repeating: " ", count: max(1, indentSpaces))
        var formatted = ""
        var indentLevel = 0

        for char in minified {
            if char == "{" {
                formatted += " {\n"
                indentLevel += 1
                formatted += String(repeating: indentUnit, count: indentLevel)
            } else if char == "}" {
                formatted += "\n"
                indentLevel = max(0, indentLevel - 1)
                formatted += String(repeating: indentUnit, count: indentLevel) + "}\n\n"
            } else if char == ";" {
                formatted += ";\n" + String(repeating: indentUnit, count: indentLevel)
            } else {
                formatted.append(char)
            }
        }

        while formatted.contains("\n\n\n") {
            formatted = formatted.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }

        return (formatted.trimmingCharacters(in: .whitespacesAndNewlines), nil)
    }

    // MARK: - JavaScript (JS) Minify & Format

    public static func minifyJs(_ rawJs: String) -> (result: String, error: String?) {
        let trimmed = rawJs.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", "Empty JS input") }

        var output = trimmed
        if let rxBlock = try? NSRegularExpression(pattern: "/\\*[\\s\\S]*?\\*/", options: []) {
            let range = NSRange(output.startIndex..<output.endIndex, in: output)
            output = rxBlock.stringByReplacingMatches(in: output, options: [], range: range, withTemplate: "")
        }

        let lines = output.components(separatedBy: "\n")
        var filteredLines: [String] = []
        for line in lines {
            let t = line.trimmingCharacters(in: .whitespaces)
            if t.hasPrefix("//") { continue }
            if let slashIdx = t.range(of: "//"), !t.contains("://") && !t.contains("\"") && !t.contains("'") {
                filteredLines.append(String(t[..<slashIdx.lowerBound]).trimmingCharacters(in: .whitespaces))
            } else {
                filteredLines.append(t)
            }
        }
        output = filteredLines.joined(separator: "\n")

        let symbols: [(String, String)] = [
            ("\\s*\\{\\s*", "{"),
            ("\\s*\\}\\s*", "}"),
            ("\\s*\\(\\s*", "("),
            ("\\s*\\)\\s*", ")"),
            ("\\s*=\\s*", "="),
            ("\\s*;\\s*", ";"),
            ("\\s*,\\s*", ","),
            ("\\s*\\+\\s*", "+")
        ]

        for (pattern, repl) in symbols {
            if let rx = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(output.startIndex..<output.endIndex, in: output)
                output = rx.stringByReplacingMatches(in: output, options: [], range: range, withTemplate: repl)
            }
        }

        return (output.trimmingCharacters(in: .whitespacesAndNewlines), nil)
    }

    public static func formatJs(_ rawJs: String, indentSpaces: Int = 2) -> (result: String, error: String?) {
        let trimmed = rawJs.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", "Empty JS input") }

        let indentUnit = String(repeating: " ", count: max(1, indentSpaces))
        var formatted = ""
        var indentLevel = 0
        var inString: Character?

        let chars = Array(trimmed)
        var i = 0

        while i < chars.count {
            let ch = chars[i]

            if let quote = inString {
                formatted.append(ch)
                if ch == quote && (i == 0 || chars[i - 1] != "\\") {
                    inString = nil
                }
            } else if ch == "\"" || ch == "'" || ch == "`" {
                inString = ch
                formatted.append(ch)
            } else if ch == "{" {
                formatted += " {\n"
                indentLevel += 1
                formatted += String(repeating: indentUnit, count: indentLevel)
            } else if ch == "}" {
                formatted += "\n"
                indentLevel = max(0, indentLevel - 1)
                formatted += String(repeating: indentUnit, count: indentLevel) + "}"
                if i + 1 < chars.count && chars[i + 1] != ";" && chars[i + 1] != ")" {
                    formatted += "\n" + String(repeating: indentUnit, count: indentLevel)
                }
            } else if ch == ";" {
                formatted += ";\n" + String(repeating: indentUnit, count: indentLevel)
            } else {
                formatted.append(ch)
            }
            i += 1
        }

        return (formatted.trimmingCharacters(in: .whitespacesAndNewlines), nil)
    }

    // MARK: - HTML Encrypt & Decrypt

    public static func encryptHtml(
        _ rawHtml: String,
        method: HtmlEncryptMethod = .javascriptEscape,
        password: String = ""
    ) -> (result: String, error: String?) {
        let trimmed = rawHtml.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", "Empty HTML content") }

        switch method {
        case .javascriptEscape:
            var escaped = ""
            for byte in trimmed.utf8 {
                escaped += String(format: "%%%02X", byte)
            }
            let script = """
            <!-- Encrypted HTML generated by NotepadMac -->
            <script type="text/javascript">
            /*<![CDATA[*/
            document.write(unescape('\(escaped)'));
            /*]]>*/
            </script>
            """
            return (script, nil)

        case .base64:
            guard let data = trimmed.data(using: .utf8) else {
                return ("", "Failed to encode UTF-8 data")
            }
            let b64 = data.base64EncodedString()
            let script = """
            <!-- Encrypted HTML generated by NotepadMac -->
            <script type="text/javascript">
            /*<![CDATA[*/
            document.write(decodeURIComponent(escape(window.atob('\(b64)'))));
            /*]]>*/
            </script>
            """
            return (script, nil)

        case .passwordProtected:
            let pass = password.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !pass.isEmpty else {
                return ("", "Password is required for password-protected HTML encryption")
            }
            let res = CryptoTools.encrypt(text: trimmed, passphrase: pass)
            guard res.success else {
                return ("", res.errorMessage ?? "Encryption failed")
            }
            let encrypted = res.data

            let containerHtml = """
            <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Protected Content</title>
              <style>
                body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; background: #0f141c; color: #e6edf3; }
                .box { background: #161b22; padding: 28px; border-radius: 12px; border: 1px solid #30363d; width: 100%; max-width: 380px; box-shadow: 0 8px 24px rgba(0,0,0,0.4); text-align: center; }
                input { width: 100%; padding: 10px 12px; margin: 16px 0; border: 1px solid #30363d; background: #0d1117; color: #fff; border-radius: 6px; box-sizing: border-box; font-size: 14px; }
                button { width: 100%; padding: 10px; background: #238636; color: #fff; border: none; border-radius: 6px; font-weight: 600; cursor: pointer; font-size: 14px; }
                button:hover { background: #2ea043; }
                .err { color: #f85149; font-size: 13px; margin-top: 10px; display: none; }
              </style>
            </head>
            <body>
              <div id="authBox" class="box">
                <h2>Protected Document</h2>
                <p style="font-size: 13px; color: #8b949e;">This HTML file is encrypted. Enter the passphrase to view contents.</p>
                <input type="password" id="pwd" placeholder="Enter passphrase..." autofocus onkeydown="if(event.key==='Enter')decrypt();" />
                <button onclick="decrypt()">Unlock & View</button>
                <div id="err" class="err">Invalid passphrase or corrupted payload</div>
              </div>
              <script>
                const payload = "\(encrypted)";
                async function decrypt() {
                  const p = document.getElementById("pwd").value;
                  const err = document.getElementById("err");
                  try {
                    const raw = atob(payload.replace(/^NPMENC01:/, ''));
                    const bytes = new Uint8Array(raw.length);
                    for (let i = 0; i < raw.length; i++) bytes[i] = raw.charCodeAt(i);
                    const salt = bytes.slice(0, 16);
                    const nonce = bytes.slice(16, 28);
                    const tag = bytes.slice(bytes.length - 16);
                    const cipher = bytes.slice(28, bytes.length - 16);
                    const enc = new TextEncoder();
                    const keyMat = await crypto.subtle.importKey("raw", enc.encode(p), {name: "PBKDF2"}, false, ["deriveKey"]);
                    const key = await crypto.subtle.deriveKey({name: "PBKDF2", salt: salt, iterations: 100000, hash: "SHA-256"}, keyMat, {name: "AES-GCM", length: 256}, false, ["decrypt"]);
                    const combined = new Uint8Array(cipher.length + tag.length);
                    combined.set(cipher);
                    combined.set(tag, cipher.length);
                    const dec = await crypto.subtle.decrypt({name: "AES-GCM", iv: nonce}, key, combined);
                    document.open();
                    document.write(new TextDecoder().decode(dec));
                    document.close();
                  } catch(e) {
                    err.style.display = "block";
                  }
                }
              </script>
            </body>
            </html>
            """
            return (containerHtml, nil)
        }
    }

    public static func decryptHtml(_ input: String) -> (result: String, error: String?) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", "Empty HTML content to decrypt") }

        if let rxUnescape = try? NSRegularExpression(pattern: "unescape\\(['\"]([^'\"]+)['\"]\\)", options: []) {
            let nsStr = trimmed as NSString
            if let match = rxUnescape.firstMatch(
                in: trimmed,
                options: [],
                range: NSRange(location: 0, length: nsStr.length)
            ) {
                let encodedPayload = nsStr.substring(with: match.range(at: 1))
                if let decoded = encodedPayload.removingPercentEncoding {
                    return (decoded, nil)
                }
            }
        }

        if let rxAtob = try? NSRegularExpression(pattern: "atob\\(['\"]([^'\"]+)['\"]\\)", options: []) {
            let nsStr = trimmed as NSString
            if let match = rxAtob.firstMatch(
                in: trimmed,
                options: [],
                range: NSRange(location: 0, length: nsStr.length)
            ) {
                let base64Payload = nsStr.substring(with: match.range(at: 1))
                let decoded = MimeTools.base64Decode(base64Payload)
                if !decoded.isEmpty {
                    return (decoded, nil)
                }
            }
        }

        if trimmed.contains("%") && !trimmed.contains("<") {
            if let decoded = trimmed.removingPercentEncoding {
                return (decoded, nil)
            }
        }

        return ("", "Unable to recognize encrypted HTML format. Supported formats: JS unescape and Base64.")
    }
}
