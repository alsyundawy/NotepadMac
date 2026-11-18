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
import CommonCrypto

public struct CryptoResult {
    public let success: Bool
    public let data: String
    public let errorMessage: String?

    public init(success: Bool, data: String, errorMessage: String? = nil) {
        self.success = success
        self.data = data
        self.errorMessage = errorMessage
    }
}

public struct PasswordStrength {
    public let score: Int // 0 to 100
    public let label: String
    public let isStrong: Bool

    public init(score: Int, label: String, isStrong: Bool) {
        self.score = score
        self.label = label
        self.isStrong = isStrong
    }
}

public enum CryptoTools {
    public static let magicHeader = "NPMENC01:"
    private static let saltLength = 16
    private static let nonceLength = 12
    private static let tagLength = 16
    private static let pbkdf2Rounds: UInt32 = 100_000

    // MARK: - Key Derivation (PBKDF2-HMAC-SHA256)

    public static func deriveKey(passphrase: String, salt: Data) -> SymmetricKey? {
        guard let passData = passphrase.data(using: .utf8) else { return nil }
        var derivedKey = Data(count: 32) // 256 bits

        let result = derivedKey.withUnsafeMutableBytes { derivedBytes in
            salt.withUnsafeBytes { saltBytes in
                passData.withUnsafeBytes { passBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passBytes.baseAddress?.assumingMemoryBound(to: Int8.self),
                        passData.count,
                        saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        pbkdf2Rounds,
                        derivedBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        32
                    )
                }
            }
        }

        guard result == kCCSuccess else { return nil }
        return SymmetricKey(data: derivedKey)
    }

    // MARK: - AES-256-GCM Encryption

    public static func encrypt(text: String, passphrase: String) -> CryptoResult {
        guard !text.isEmpty else {
            return CryptoResult(success: false, data: "", errorMessage: "Input text is empty")
        }
        guard !passphrase.isEmpty else {
            return CryptoResult(success: false, data: "", errorMessage: "Passphrase cannot be empty")
        }
        guard let plaintext = text.data(using: .utf8) else {
            return CryptoResult(success: false, data: "", errorMessage: "Encoding error")
        }

        // Generate 16 bytes cryptographically secure salt
        var salt = Data(count: saltLength)
        let saltStatus = salt.withUnsafeMutableBytes { buf -> Int32 in
            guard let base = buf.baseAddress else { return errSecAllocate }
            return SecRandomCopyBytes(kSecRandomDefault, saltLength, base)
        }
        guard saltStatus == errSecSuccess else {
            return CryptoResult(success: false, data: "", errorMessage: "Failed to generate cryptographic salt")
        }

        guard let key = deriveKey(passphrase: passphrase, salt: salt) else {
            return CryptoResult(success: false, data: "", errorMessage: "Key derivation failed")
        }

        do {
            let sealedBox = try AES.GCM.seal(plaintext, using: key)
            let nonce = Data(sealedBox.nonce)
            let tag = sealedBox.tag
            let ciphertext = sealedBox.ciphertext

            // Package into payload: Salt[16] + Nonce[12] + Tag[16] + Ciphertext
            var payload = Data()
            payload.append(salt)
            payload.append(nonce)
            payload.append(tag)
            payload.append(ciphertext)

            let finalEncrypted = magicHeader + payload.base64EncodedString()
            return CryptoResult(success: true, data: finalEncrypted)
        } catch {
            return CryptoResult(success: false, data: "", errorMessage: "Encryption failed: \(error.localizedDescription)")
        }
    }

    // MARK: - AES-256-GCM Decryption

    public static func decrypt(ciphertext: String, passphrase: String) -> CryptoResult {
        let trimmed = ciphertext.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix(magicHeader) else {
            return CryptoResult(
                success: false,
                data: "",
                errorMessage: "Invalid container format. Missing '\(magicHeader)' header"
            )
        }
        guard !passphrase.isEmpty else {
            return CryptoResult(success: false, data: "", errorMessage: "Passphrase cannot be empty")
        }

        let base64Part = String(trimmed.dropFirst(magicHeader.count))
        guard let payload = Data(base64Encoded: base64Part) else {
            return CryptoResult(success: false, data: "", errorMessage: "Corrupted Base64 ciphertext")
        }

        let headerMetaLength = saltLength + nonceLength + tagLength
        guard payload.count > headerMetaLength else {
            return CryptoResult(success: false, data: "", errorMessage: "Ciphertext is too short or corrupted")
        }

        let salt = payload.subdata(in: 0..<saltLength)
        let nonceData = payload.subdata(in: saltLength..<(saltLength + nonceLength))
        let tag = payload.subdata(in: (saltLength + nonceLength)..<headerMetaLength)
        let encryptedBytes = payload.subdata(in: headerMetaLength..<payload.count)

        guard let key = deriveKey(passphrase: passphrase, salt: salt) else {
            return CryptoResult(success: false, data: "", errorMessage: "Key derivation failed")
        }

        do {
            let nonce = try AES.GCM.Nonce(data: nonceData)
            let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: encryptedBytes, tag: tag)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)

            guard let plainText = String(data: decryptedData, encoding: .utf8) else {
                return CryptoResult(success: false, data: "", errorMessage: "Decrypted data is not valid UTF-8")
            }
            return CryptoResult(success: true, data: plainText)
        } catch {
            return CryptoResult(
                success: false,
                data: "",
                errorMessage: "Decryption failed. Incorrect passphrase or tampered ciphertext"
            )
        }
    }

    public static func isEncryptedText(_ text: String) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix(magicHeader)
    }

    // MARK: - Password Strength Evaluator

    public static func evaluatePasswordStrength(_ password: String) -> PasswordStrength {
        guard !password.isEmpty else {
            return PasswordStrength(score: 0, label: "Empty", isStrong: false)
        }

        var score = 0
        let len = password.count

        if len >= 8 { score += 20 }
        if len >= 12 { score += 20 }
        if len >= 16 { score += 15 }

        let hasLower = password.contains(where: { $0.isLowercase })
        let hasUpper = password.contains(where: { $0.isUppercase })
        let hasDigit = password.contains(where: { $0.isNumber })
        let hasSymbol = password.contains(where: { !$0.isLetter && !$0.isNumber })

        if hasLower { score += 10 }
        if hasUpper { score += 10 }
        if hasDigit { score += 10 }
        if hasSymbol { score += 15 }

        score = min(100, score)

        let label: String
        let isStrong: Bool
        if score < 40 {
            label = "Weak"
            isStrong = false
        } else if score < 70 {
            label = "Moderate"
            isStrong = false
        } else {
            label = "Strong"
            isStrong = true
        }

        return PasswordStrength(score: score, label: label, isStrong: isStrong)
    }
}
