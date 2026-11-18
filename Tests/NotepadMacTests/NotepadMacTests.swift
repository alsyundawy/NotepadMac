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

#if canImport(XCTest)
import XCTest
@testable import NotepadMac
import ScintillaCocoa
import CLua

// MARK: - Mock Editor Delegate

final class MockEditorDelegate: EditorActionDelegate {
    var text: String = "Hello NotepadMac\nLine 2\nLine 3"
    var selection: String = "NotepadMac"
    var lineCount: Int = 3
    var currentLine: Int = 1

    func editorGetText() -> String {
        return text
    }

    func editorSetText(_ newText: String) {
        self.text = newText
    }

    func editorGetSelection() -> String {
        return selection
    }

    func editorReplaceSelection(_ newText: String) {
        self.text = self.text.replacingOccurrences(of: selection, with: newText)
    }

    func editorGetLineCount() -> Int {
        return lineCount
    }

    func editorGetCurrentLine() -> Int {
        return currentLine
    }

    func editorInsertText(at position: Int, text: String) {
        self.text.append(text)
    }

    func editorClear() {
        self.text = ""
    }

    func editorZoomIn() {}
    func editorZoomOut() {}
}

// MARK: - Main Test Suite

final class NotepadMacTests: XCTestCase {

    // MARK: - Pillar 1-4: Theme color correctness (Bug, Syntax, Logic)

    func testThemeScintillaColorRef() {
        let sparkLight = Theme.sparkNotepadLight
        XCTAssertFalse(sparkLight.isDark)
        XCTAssertEqual(sparkLight.name, "SparkNotePad Light")
        XCTAssertEqual(sparkLight.backgroundHex, "#fafbfc")
        XCTAssertEqual(sparkLight.lineNumberBgHex, "#f0f2f5")
        XCTAssertEqual(sparkLight.caretHex, "#0969da")

        let sparkDark = Theme.sparkNotepadDark
        XCTAssertTrue(sparkDark.isDark)
        XCTAssertEqual(sparkDark.name, "SparkNotePad Dark")
        XCTAssertEqual(sparkDark.backgroundHex, "#1e1e2e")

        let oneDark = Theme.oneDarkPro
        XCTAssertTrue(oneDark.isDark)
        XCTAssertEqual(oneDark.name, "One Dark Pro")

        // Scintilla BGR encoding: red=(R=255,G=0,B=0) → BGR=0x0000FF=255
        let red = NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        XCTAssertEqual(red.scintillaColorRef, 255)

        // Scintilla BGR encoding: blue=(R=0,G=0,B=255) → BGR=0xFF0000=16711680
        let blue = NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        XCTAssertEqual(blue.scintillaColorRef, 16711680)

        // All 15 themes registered (including SparkNotePad ported themes)
        XCTAssertEqual(Theme.allThemes.count, 15)
        XCTAssertEqual(Theme.catppuccinMocha.name, "Catppuccin Mocha")
        XCTAssertTrue(Theme.catppuccinMocha.isDark)
        XCTAssertEqual(Theme.catppuccinLatte.name, "Catppuccin Latte")
        XCTAssertFalse(Theme.catppuccinLatte.isDark)
        XCTAssertEqual(Theme.tokyoNight.name, "Tokyo Night")
        XCTAssertEqual(Theme.nordDark.name, "Nord Dark")
    }

    // MARK: - Pillar 4: LexerRegistry logic correctness

    func testLexerRegistryLanguageLookup() {
        let registry = LexerRegistry.shared
        XCTAssertFalse(registry.languages.isEmpty)

        // Extension-based lookup
        XCTAssertEqual(registry.language(forExtension: "swift").id, "swift")
        XCTAssertEqual(registry.language(forExtension: "py").id, "python")
        XCTAssertEqual(registry.language(forExtension: "js").id, "javascript")
        XCTAssertEqual(registry.language(forExtension: "json").id, "json")
        XCTAssertEqual(registry.language(forExtension: "md").id, "markdown")
        XCTAssertEqual(registry.language(forExtension: "cpp").id, "cpp")
        XCTAssertEqual(registry.language(forExtension: "sh").id, "bash")
        XCTAssertEqual(registry.language(forExtension: "html").id, "html")
        XCTAssertEqual(registry.language(forExtension: "xml").id, "xml")
        XCTAssertEqual(registry.language(forExtension: "yml").id, "yaml")

        // Unknown extension falls back to first language (plain_text)
        XCTAssertEqual(registry.language(forExtension: "unknown_ext").id, "plain_text")

        // Case-insensitive extension match
        XCTAssertEqual(registry.language(forExtension: ".PY").id, "python")
        XCTAssertEqual(registry.language(forExtension: "SWIFT").id, "swift")

        // ID-based lookup
        XCTAssertEqual(registry.language(forId: "lua").id, "lua")
        XCTAssertEqual(registry.language(forId: "rust").id, "rust")
        XCTAssertEqual(registry.language(forId: "nonexistent").id, "plain_text")
    }

    // MARK: - Pillar 1-4: Lua engine execution (Bug, Logic, Runtime)

    func testLuaEngineExecution() {
        let engine = LuaEngine()
        let mock = MockEditorDelegate()

        let script = """
        local text = editor.getText()
        editor.setText(text .. "\\nAppended by Lua 5.5.1")
        print("Script executed successfully")
        """

        let result = engine.execute(script: script, delegate: mock)
        XCTAssertTrue(result.success, "Lua script should execute without error. Error: \(result.error ?? "none")")
        XCTAssertTrue(result.output.contains("Script executed successfully"))
        XCTAssertTrue(mock.text.contains("Appended by Lua 5.5.1"))
    }

    func testLuaEngineGetLineCount() {
        let engine = LuaEngine()
        let mock = MockEditorDelegate()

        let result = engine.execute(
            script: "local n = editor.getLineCount(); print(tostring(n))",
            delegate: mock
        )
        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output.contains("3"))
    }

    func testLuaEngineClear() {
        let engine = LuaEngine()
        let mock = MockEditorDelegate()

        let result = engine.execute(script: "editor.clear()", delegate: mock)
        XCTAssertTrue(result.success)
        XCTAssertEqual(mock.text, "")
    }

    func testLuaEngineReset() {
        let engine = LuaEngine()
        let mock = MockEditorDelegate()

        _ = engine.execute(script: "x = 42", delegate: mock)
        engine.reset()

        // After reset the global x should be gone
        let result = engine.execute(
            script: "if x == nil then print(\"x is nil\") end",
            delegate: mock
        )
        XCTAssertTrue(result.success)
        XCTAssertTrue(result.output.contains("x is nil"))
    }

    func testLuaEngineSyntaxError() {
        let engine = LuaEngine()
        let result = engine.execute(script: "if then end", delegate: nil)
        XCTAssertFalse(result.success)
        XCTAssertNotNil(result.error)
    }

    // MARK: - Pillar 5: DocumentManager (Memory, Object lifecycle)

    func testDocumentManager() {
        let manager = DocumentManager()
        XCTAssertFalse(manager.documents.isEmpty)
        let initialDocCount = manager.documents.count

        manager.newDocument()
        XCTAssertEqual(manager.documents.count, initialDocCount + 1)

        let activeDoc = manager.activeDocument
        XCTAssertNotNil(activeDoc)

        // Modify document
        activeDoc?.content = "Updated content"
        XCTAssertTrue(activeDoc?.isModified ?? false)

        // Close document
        if let docID = activeDoc?.id {
            manager.closeDocument(id: docID)
            XCTAssertEqual(manager.documents.count, initialDocCount)
        }
    }

    func testFindReplaceDialogState() {
        let manager = DocumentManager()
        XCTAssertFalse(manager.isFindReplaceDialogPresented)
        XCTAssertEqual(manager.findDialogTab, 0)
        XCTAssertTrue(manager.isWrapAround)
        XCTAssertFalse(manager.searchDirectionUp)

        // Open Find dialog
        manager.findDialogTab = 0
        manager.isFindReplaceDialogPresented = true
        XCTAssertTrue(manager.isFindReplaceDialogPresented)
        XCTAssertEqual(manager.findDialogTab, 0)

        // Switch to Replace dialog
        manager.findDialogTab = 1
        XCTAssertEqual(manager.findDialogTab, 1)

        // Query state
        manager.searchQuery = "test"
        manager.replaceQuery = "replacement"
        manager.isMatchCase = true
        manager.isWholeWord = true
        manager.isRegex = true
        XCTAssertEqual(manager.searchQuery, "test")
        XCTAssertEqual(manager.replaceQuery, "replacement")
        XCTAssertTrue(manager.isMatchCase)
        XCTAssertTrue(manager.isWholeWord)
        XCTAssertTrue(manager.isRegex)
    }

    func testExtendedLanguagesCatalog() {
        let registry = LexerRegistry.shared
        XCTAssertGreaterThanOrEqual(registry.languages.count, 50)

        // Extended language extension lookups
        XCTAssertEqual(registry.language(forExtension: "ada").id, "ada")
        XCTAssertEqual(registry.language(forExtension: "asm").id, "asm")
        XCTAssertEqual(registry.language(forExtension: "pas").id, "pascal")
        XCTAssertEqual(registry.language(forExtension: "f90").id, "fortran")
        XCTAssertEqual(registry.language(forExtension: "kt").id, "kotlin")
        XCTAssertEqual(registry.language(forExtension: "jl").id, "julia")
        XCTAssertEqual(registry.language(forExtension: "r").id, "r")
        XCTAssertEqual(registry.language(forExtension: "v").id, "verilog")
        XCTAssertEqual(registry.language(forExtension: "vhd").id, "vhdl")
        XCTAssertEqual(registry.language(forExtension: "vb").id, "vb")

        // Alphabetical groupings
        XCTAssertEqual(registry.plainTextLanguage.id, "plain_text")
        let groups = registry.alphabeticalGroups
        XCTAssertFalse(groups.isEmpty)
        let letters = groups.map { $0.letter }
        XCTAssertEqual(letters, letters.sorted())
        for group in groups {
            XCTAssertFalse(group.languages.isEmpty)
            let names = group.languages.map { $0.displayName }
            XCTAssertEqual(
                names,
                names.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            )
        }
    }

    func testDocumentManagerViewOptions() {
        let manager = DocumentManager()
        XCTAssertFalse(manager.showWhiteSpace)
        XCTAssertTrue(manager.showIndentGuides)

        manager.showWhiteSpace.toggle()
        XCTAssertTrue(manager.showWhiteSpace)

        manager.showIndentGuides.toggle()
        XCTAssertFalse(manager.showIndentGuides)
    }

    // MARK: - Pillar 10: Security — hex parser edge cases (CWE-20 Input Validation)

    func testNSColorHexParserEdgeCases() {
        // Valid 6-char hex
        let white = NSColor(hex: "#ffffff")
        XCTAssertEqual(white.redComponent, 1.0, accuracy: 0.01)
        XCTAssertEqual(white.greenComponent, 1.0, accuracy: 0.01)
        XCTAssertEqual(white.blueComponent, 1.0, accuracy: 0.01)

        // Valid without # prefix
        let black = NSColor(hex: "000000")
        XCTAssertEqual(black.redComponent, 0.0, accuracy: 0.01)

        // Invalid hex → fallback gray (0.5, 0.5, 0.5)
        let invalid = NSColor(hex: "ZZZZZZ")
        XCTAssertEqual(invalid.redComponent, 0.5, accuracy: 0.01)
        XCTAssertEqual(invalid.greenComponent, 0.5, accuracy: 0.01)
        XCTAssertEqual(invalid.blueComponent, 0.5, accuracy: 0.01)

        // Empty string → fallback gray
        let empty = NSColor(hex: "")
        XCTAssertEqual(empty.redComponent, 0.5, accuracy: 0.01)
    }

    // MARK: - New Tools Suite Tests (Hash, MIME, Converter, Crypto, Developer)

    func testHashTools() {
        let input = "SparkNotePad & NotepadMac 2026"
        let md5 = HashTools.computeHash(input, algorithm: .md5)
        let sha1 = HashTools.computeHash(input, algorithm: .sha1)
        let sha256 = HashTools.computeHash(input, algorithm: .sha256)
        let sha384 = HashTools.computeHash(input, algorithm: .sha384)
        let sha512 = HashTools.computeHash(input, algorithm: .sha512)
        let crc32 = HashTools.computeHash(input, algorithm: .crc32)

        XCTAssertEqual(md5.count, 32)
        XCTAssertEqual(sha1.count, 40)
        XCTAssertEqual(sha256.count, 64)
        XCTAssertEqual(sha384.count, 96)
        XCTAssertEqual(sha512.count, 128)
        XCTAssertEqual(crc32.count, 8)

        // Empty input known hashes
        XCTAssertEqual(HashTools.computeHash("", algorithm: .md5), "d41d8cd98f00b204e9800998ecf8427e")
        XCTAssertEqual(HashTools.computeHash("", algorithm: .sha256), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    }

    func testMimeTools() {
        let plain = "Hello NotepadMac!\nSpecial: äöü & 123"
        let b64 = MimeTools.base64Encode(plain)
        XCTAssertEqual(MimeTools.base64Decode(b64), plain)

        // URL encode / decode
        let url = "https://example.com/search?q=notepad mac & key=val"
        let urlEnc = MimeTools.urlEncode(url)
        XCTAssertFalse(urlEnc.contains(" "))
        XCTAssertEqual(MimeTools.urlDecode(urlEnc), url)

        // HTML entities
        let html = "<div class=\"test\">Tom & Jerry 'fun'</div>"
        let htmlEnc = MimeTools.htmlEntityEncode(html)
        XCTAssertTrue(htmlEnc.contains("&lt;"))
        XCTAssertTrue(htmlEnc.contains("&amp;"))
        XCTAssertEqual(MimeTools.htmlEntityDecode(htmlEnc), html)

        // Quoted printable
        let qpEnc = MimeTools.quotedPrintableEncode("Hello = World!")
        XCTAssertTrue(qpEnc.contains("=3D"))
        XCTAssertEqual(MimeTools.quotedPrintableDecode(qpEnc), "Hello = World!")
    }

    func testConverterTools() {
        // ASCII <-> HEX
        let text = "ABC 123"
        let hex = ConverterTools.asciiToHex(text)
        XCTAssertEqual(hex, "41 42 43 20 31 32 33")
        XCTAssertEqual(ConverterTools.hexToAscii(hex), text)

        // Number base
        XCTAssertEqual(ConverterTools.convertNumber("255", from: .decimal, to: .hexadecimal), "0xFF")
        XCTAssertEqual(ConverterTools.convertNumber("0xFF", from: .hexadecimal, to: .decimal), "255")
        XCTAssertEqual(ConverterTools.convertNumber("10", from: .decimal, to: .binary), "0b1010")
        XCTAssertEqual(ConverterTools.convertNumber("0b1010", from: .binary, to: .decimal), "10")

        // Case conversions
        XCTAssertEqual(ConverterTools.toUpperCase("test"), "TEST")
        XCTAssertEqual(ConverterTools.toLowerCase("TEST"), "test")
        XCTAssertEqual(ConverterTools.toTitleCase("hello world"), "Hello World")
        XCTAssertEqual(ConverterTools.toInvertCase("Hello World"), "hELLO wORLD")
        XCTAssertEqual(ConverterTools.toSentenceCase("hello. world."), "Hello. World.")
    }

    func testCryptoTools() {
        let plain = "TopSecretPassword#2026!"
        let pass = "MasterKey_NotepadMac"

        let enc = CryptoTools.encrypt(text: plain, passphrase: pass)
        XCTAssertTrue(enc.success)
        XCTAssertTrue(CryptoTools.isEncryptedText(enc.data))

        // Correct decryption
        let dec = CryptoTools.decrypt(ciphertext: enc.data, passphrase: pass)
        XCTAssertTrue(dec.success)
        XCTAssertEqual(dec.data, plain)

        // Wrong passphrase rejection
        let decWrong = CryptoTools.decrypt(ciphertext: enc.data, passphrase: "WrongPassword")
        XCTAssertFalse(decWrong.success)

        // Password strength
        let weak = CryptoTools.evaluatePasswordStrength("123")
        XCTAssertFalse(weak.isStrong)
        let strong = CryptoTools.evaluatePasswordStrength("N0t3p@dM@c_2026!ProSecret")
        XCTAssertTrue(strong.isStrong)
    }

    func testDeveloperTools() {
        // JSON Prettify & Minify
        let raw = "{\"name\":\"NotepadMac\",\"version\":\"1.0.0\",\"items\":[1,2,3]}"
        let formatted = DeveloperTools.formatJson(raw, indentSpaces: 2)
        XCTAssertNil(formatted.error)
        XCTAssertTrue(formatted.result.contains("\n"))

        let minified = DeveloperTools.minifyJson(formatted.result)
        XCTAssertNil(minified.error)
        XCTAssertFalse(minified.result.contains("\n"))

        // XML Formatter
        let rawXml = "<root><item id=\"1\">test</item></root>"
        let formattedXml = DeveloperTools.formatXml(rawXml)
        XCTAssertNil(formattedXml.error)
        XCTAssertTrue(formattedXml.result.contains("<root>"))

        // UUID
        let uuid = DeveloperTools.generateUuid(uppercase: true, braces: true, hyphens: true)
        XCTAssertTrue(uuid.hasPrefix("{"))
        XCTAssertTrue(uuid.hasSuffix("}"))

        // Epoch
        let epoch: Int64 = 1767225600
        let iso = DeveloperTools.epochToIso(epoch)
        XCTAssertTrue(iso.contains("2026"))
        let roundtrip = DeveloperTools.isoToEpoch(iso)
        XCTAssertEqual(roundtrip, epoch)
    }

    func testLocalizationManager() {
        let manager = LocalizationManager.shared
        manager.currentLanguage = .english
        XCTAssertEqual(manager.localized("ready"), "Ready")
        XCTAssertEqual(manager.localized("new_tab"), "New Tab")

        manager.currentLanguage = .indonesian
        XCTAssertEqual(manager.localized("ready"), "Siap")
        XCTAssertEqual(manager.localized("new_tab"), "Tab Baru")
    }

    func testAutoHighlightAndLexerDetection() {
        let registry = LexerRegistry.shared

        // Shebang detection
        let bashContent = "#!/bin/bash\necho 'hello'"
        XCTAssertEqual(registry.detectLanguage(forFilename: "myscript", content: bashContent).id, "bash")

        let pythonContent = "#!/usr/bin/env python3\nprint('hello')"
        XCTAssertEqual(registry.detectLanguage(forFilename: "runner", content: pythonContent).id, "python")

        let phpContent = "<?php\necho 'hello';"
        XCTAssertEqual(registry.detectLanguage(forFilename: "index", content: phpContent).id, "php")

        // Exact filenames
        XCTAssertEqual(registry.detectLanguage(forFilename: "Makefile", content: "").id, "makefile")
        XCTAssertEqual(registry.detectLanguage(forFilename: "Dockerfile", content: "").id, "dockerfile")
        XCTAssertEqual(registry.detectLanguage(forFilename: "CMakeLists.txt", content: "").id, "cmake")
    }

    func testDocumentModificationAndCloseGuards() {
        let docMgr = DocumentManager()
        guard let doc = docMgr.activeDocument else {
            XCTFail("Active document should exist")
            return
        }

        XCTAssertFalse(doc.isModified)
        // Closing unmodified document should succeed immediately
        let closedUnmodified = docMgr.closeDocument(id: doc.id)
        XCTAssertTrue(closedUnmodified)

        // Create new doc and modify
        let newDoc = docMgr.newDocument(title: "TestDoc", content: "Initial content")
        XCTAssertFalse(newDoc.isModified)
        newDoc.content = "Modified content"
        XCTAssertTrue(newDoc.isModified)

        // confirmCloseDocument on unmodified doc returns true
        newDoc.isModified = false
        XCTAssertTrue(docMgr.confirmCloseDocument(newDoc))
    }

    func testFindReplaceAndMarkProperties() {
        let docMgr = DocumentManager()
        docMgr.searchQuery = "hello"
        docMgr.replaceQuery = "world"
        docMgr.isMatchCase = true
        docMgr.isWholeWord = true
        docMgr.isRegex = true
        docMgr.isWrapAround = true
        docMgr.isBookmarkLine = true
        docMgr.isPurgeOnSearch = true
        docMgr.findDialogTab = 2

        XCTAssertEqual(docMgr.searchQuery, "hello")
        XCTAssertEqual(docMgr.replaceQuery, "world")
        XCTAssertTrue(docMgr.isMatchCase)
        XCTAssertTrue(docMgr.isWholeWord)
        XCTAssertTrue(docMgr.isRegex)
        XCTAssertTrue(docMgr.isWrapAround)
        XCTAssertTrue(docMgr.isBookmarkLine)
        XCTAssertTrue(docMgr.isPurgeOnSearch)
        XCTAssertEqual(docMgr.findDialogTab, 2)
    }
}
#endif
