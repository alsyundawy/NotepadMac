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

public enum NumberBase: String, CaseIterable, Identifiable {
    case binary = "Binary (2)"
    case octal = "Octal (8)"
    case decimal = "Decimal (10)"
    case hexadecimal = "Hexadecimal (16)"

    public var id: String { rawValue }

    public var radix: Int {
        switch self {
        case .binary: return 2
        case .octal: return 8
        case .decimal: return 10
        case .hexadecimal: return 16
        }
    }
}

public enum ConverterTools {

    // MARK: - ASCII <-> Hex

    public static func asciiToHex(_ text: String, separator: String = " ") -> String {
        guard let data = text.data(using: .utf8) else { return "" }
        return data.map { String(format: "%02X", $0) }.joined(separator: separator)
    }

    public static func hexToAscii(_ hex: String) -> String {
        let clean = hex
            .replacingOccurrences(of: "0x", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\t", with: "")

        guard clean.count % 2 == 0 else {
            return "Error: Invalid Hex string (odd length)"
        }

        var bytes = [UInt8]()
        var index = clean.startIndex
        while index < clean.endIndex {
            let nextIndex = clean.index(index, offsetBy: 2)
            let byteStr = String(clean[index..<nextIndex])
            if let byte = UInt8(byteStr, radix: 16) {
                bytes.append(byte)
            } else {
                return "Error: Invalid Hex characters"
            }
            index = nextIndex
        }

        return String(bytes: bytes, encoding: .utf8) ?? "Error: Unable to decode UTF-8"
    }

    // MARK: - Number Base Conversion

    public static func convertNumber(
        _ input: String,
        from sourceBase: NumberBase,
        to targetBase: NumberBase
    ) -> String {
        var clean = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if sourceBase == .hexadecimal, clean.lowercased().hasPrefix("0x") {
            clean = String(clean.dropFirst(2))
        } else if sourceBase == .binary, clean.lowercased().hasPrefix("0b") {
            clean = String(clean.dropFirst(2))
        } else if sourceBase == .octal, clean.lowercased().hasPrefix("0o") {
            clean = String(clean.dropFirst(2))
        }

        guard let value = Int64(clean, radix: sourceBase.radix) else {
            return "Error: Invalid number for base \(sourceBase.radix)"
        }

        switch targetBase {
        case .binary:
            return "0b" + String(value, radix: 2)
        case .octal:
            return "0o" + String(value, radix: 8)
        case .decimal:
            return String(value, radix: 10)
        case .hexadecimal:
            return "0x" + String(value, radix: 16).uppercased()
        }
    }

    // MARK: - Case Conversion Suite

    public static func toUpperCase(_ text: String) -> String {
        text.uppercased()
    }

    public static func toLowerCase(_ text: String) -> String {
        text.lowercased()
    }

    public static func toTitleCase(_ text: String) -> String {
        text.capitalized
    }

    public static func toInvertCase(_ text: String) -> String {
        text.map { char -> String in
            let str = String(char)
            if str == str.uppercased() {
                return str.lowercased()
            } else {
                return str.uppercased()
            }
        }.joined()
    }

    public static func toSentenceCase(_ text: String) -> String {
        var result = ""
        var capitalizeNext = true

        for char in text {
            if capitalizeNext && char.isLetter {
                result.append(char.uppercased())
                capitalizeNext = false
            } else {
                result.append(char.lowercased())
            }

            if char == "." || char == "!" || char == "?" {
                capitalizeNext = true
            }
        }
        return result
    }
}
