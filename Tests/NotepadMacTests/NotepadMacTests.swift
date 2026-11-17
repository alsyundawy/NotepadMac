//
//  NotepadMacTests.swift
//  NotepadMacTests
//

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

        // All 7 themes registered
        XCTAssertEqual(Theme.allThemes.count, 7)
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
}
#endif
