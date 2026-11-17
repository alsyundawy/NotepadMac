//
//  ScintillaEditorRepresentable.swift
//  NotepadMac
//
//  SwiftUI NSViewRepresentable wrapper for ScintillaView Cocoa editor
//

import AppKit
import SwiftUI
import ScintillaCocoa

enum SciMsg {
    static let setMultipleSelection: UInt32 = 2563
    static let setAdditionalSelectionTyping: UInt32 = 2565
    static let setAdditionalCaretsBlink: UInt32 = 2567
    static let setAdditionalCaretsVisible: UInt32 = 2608
    static let styleSetFont: UInt32 = 2056
    static let styleSetSize: UInt32 = 2055
    static let styleSetFore: UInt32 = 2051
    static let styleSetBack: UInt32 = 2052
    static let styleClearAll: UInt32 = 2050
    static let setCaretFore: UInt32 = 2069
    static let setCaretPeriod: UInt32 = 2076
    static let setCaretLineVisible: UInt32 = 2096
    static let setCaretLineBack: UInt32 = 2098
    static let setCaretLineBackAlpha: UInt32 = 2470
    static let setSelBack: UInt32 = 2068
    static let setSelFore: UInt32 = 2067
    static let setAdditionalSelBack: UInt32 = 2601
    static let setAdditionalSelFore: UInt32 = 2600
    static let setMarginBackN: UInt32 = 2250
    static let setFoldMarginColour: UInt32 = 2290
    static let setFoldMarginHiColour: UInt32 = 2291
    static let markerSetFore: UInt32 = 2041
    static let markerSetBack: UInt32 = 2042
}

public struct ScintillaEditorRepresentable: NSViewRepresentable {
    @Binding public var text: String
    @Binding public var cursorLine: Int
    @Binding public var cursorColumn: Int
    @Binding public var selectionLength: Int
    @Binding public var isModified: Bool

    public var fontName: String
    public var fontSize: Int
    public var isWordWrapEnabled: Bool
    public var showLineNumbers: Bool
    public var showFolding: Bool
    public var showWhiteSpace: Bool
    public var showIndentGuides: Bool
    public var theme: Theme
    public var language: LanguageDefinition
    public var zoomOffset: Int
    public var documentManager: DocumentManager?

    public init(
        text: Binding<String>,
        cursorLine: Binding<Int>,
        cursorColumn: Binding<Int>,
        selectionLength: Binding<Int>,
        isModified: Binding<Bool>,
        fontName: String = "Menlo",
        fontSize: Int = 13,
        isWordWrapEnabled: Bool = false,
        showLineNumbers: Bool = true,
        showFolding: Bool = true,
        showWhiteSpace: Bool = false,
        showIndentGuides: Bool = true,
        theme: Theme = .sparkNotepadLight,
        language: LanguageDefinition = LexerRegistry.shared.plainTextLanguage,
        zoomOffset: Int = 0,
        documentManager: DocumentManager? = nil
    ) {
        self._text = text
        self._cursorLine = cursorLine
        self._cursorColumn = cursorColumn
        self._selectionLength = selectionLength
        self._isModified = isModified
        self.fontName = fontName
        self.fontSize = fontSize
        self.isWordWrapEnabled = isWordWrapEnabled
        self.showLineNumbers = showLineNumbers
        self.showFolding = showFolding
        self.showWhiteSpace = showWhiteSpace
        self.showIndentGuides = showIndentGuides
        self.theme = theme
        self.language = language
        self.zoomOffset = zoomOffset
        self.documentManager = documentManager
    }

    public func makeCoordinator() -> ScintillaEditorCoordinator {
        ScintillaEditorCoordinator(self)
    }

    public func makeNSView(context: Context) -> ScintillaView {
        let view = ScintillaView(frame: .zero)
        view.delegate = context.coordinator
        context.coordinator.scintillaView = view
        view.menu = context.coordinator.buildEditorContextMenu()

        view.appearance = NSAppearance(named: theme.isDark ? .darkAqua : .aqua)

        configureEditorMargins(view: view)
        configureMultiSelection(view: view)
        context.coordinator.setupHighlightIndicator()
        applyFont(view: view, fontName: fontName, fontSize: fontSize)
        applyTheme(view: view, theme: theme)
        applyLanguage(view: view, language: language)

        view.setString(text)
        view.message(UInt32(4003), wParam: 0, lParam: -1) // SCI_COLOURISE
        view.message(UInt32(SCI_SETSAVEPOINT))
        view.message(UInt32(SCI_EMPTYUNDOBUFFER))

        return view
    }

    public func updateNSView(_ view: ScintillaView, context: Context) {
        context.coordinator.parent = self

        if !context.coordinator.isUpdatingFromScintilla {
            let currentText = view.string() ?? ""
            if currentText != text {
                view.setString(text)
                view.message(UInt32(4003), wParam: 0, lParam: -1) // SCI_COLOURISE
            }
        }

        let currentWrap = view.message(UInt32(SCI_GETWRAPMODE))
        let targetWrap = isWordWrapEnabled ? UInt32(SC_WRAP_WORD) : UInt32(SC_WRAP_NONE)
        if currentWrap != targetWrap {
            view.message(UInt32(SCI_SETWRAPMODE), wParam: UInt(targetWrap))
        }

        let lineMarginWidth = showLineNumbers ? calculateLineMarginWidth(view: view) : 0
        view.message(UInt32(SCI_SETMARGINWIDTHN), wParam: 0, lParam: lineMarginWidth)

        let foldMarginWidth = showFolding ? 16 : 0
        view.message(UInt32(SCI_SETMARGINWIDTHN), wParam: 2, lParam: foldMarginWidth)

        let wsMode = showWhiteSpace ? UInt32(1) : UInt32(0) // SCWS_VISIBLEALWAYS : SCWS_INVISIBLE
        view.message(UInt32(2021), wParam: UInt(wsMode)) // SCI_SETVIEWWS
        view.message(UInt32(2356), wParam: showWhiteSpace ? 1 : 0) // SCI_SETVIEWEOL

        let guideMode = showIndentGuides ? UInt32(3) : UInt32(0) // SC_IV_LOOKBOTH : SC_IV_NONE
        view.message(UInt32(2132), wParam: UInt(guideMode)) // SCI_SETINDENTATIONGUIDES

        updateAppearance(view: view, context: context)
        view.message(UInt32(SCI_SETZOOM), wParam: UInt(bitPattern: zoomOffset))
    }

    private func updateAppearance(view: ScintillaView, context: Context) {
        if context.coordinator.lastFontName != fontName ||
            context.coordinator.lastFontSize != fontSize {
            applyFont(view: view, fontName: fontName, fontSize: fontSize)
            context.coordinator.lastFontName = fontName
            context.coordinator.lastFontSize = fontSize
        }

        if context.coordinator.lastThemeID != theme.id {
            view.appearance = NSAppearance(named: theme.isDark ? .darkAqua : .aqua)
            applyTheme(view: view, theme: theme)
            context.coordinator.lastThemeID = theme.id
        }

        if context.coordinator.lastLanguageID != language.id {
            applyLanguage(view: view, language: language)
            context.coordinator.lastLanguageID = language.id
        }
    }
}

// MARK: - Styling & Lexer Configuration

extension ScintillaEditorRepresentable {
    func configureEditorMargins(view: ScintillaView) {
        view.message(UInt32(SCI_SETMARGINTYPEN), wParam: 0, lParam: Int(SC_MARGIN_NUMBER))
        view.message(UInt32(SCI_SETMARGINWIDTHN), wParam: 0, lParam: 42)
        view.message(UInt32(SCI_SETMARGINSENSITIVEN), wParam: 0, lParam: 0)

        view.message(UInt32(SCI_SETMARGINTYPEN), wParam: 1, lParam: Int(SC_MARGIN_SYMBOL))
        view.message(UInt32(SCI_SETMARGINWIDTHN), wParam: 1, lParam: 4)
        view.message(UInt32(SCI_SETMARGINMASKN), wParam: 1, lParam: 0)

        view.message(UInt32(SCI_SETMARGINTYPEN), wParam: 2, lParam: Int(SC_MARGIN_SYMBOL))
        view.message(UInt32(SCI_SETMARGINWIDTHN), wParam: 2, lParam: 16)
        view.message(
            UInt32(SCI_SETMARGINMASKN),
            wParam: 2,
            lParam: Int(bitPattern: UInt(SC_MASK_FOLDERS))
        )
        view.message(UInt32(SCI_SETMARGINSENSITIVEN), wParam: 2, lParam: 1)
        view.message(UInt32(SCI_SETMARGINCURSORN), wParam: 2, lParam: 1)

        configureFolderMarkers(view: view)
        view.message(UInt32(SCI_SETFOLDFLAGS), wParam: 16, lParam: 0)
    }

    func configureFolderMarkers(view: ScintillaView) {
        let markers: [(Int32, Int32)] = [
            (SC_MARKNUM_FOLDEROPEN, SC_MARK_BOXMINUS),
            (SC_MARKNUM_FOLDER, SC_MARK_BOXPLUS),
            (SC_MARKNUM_FOLDERSUB, SC_MARK_VLINE),
            (SC_MARKNUM_FOLDERTAIL, SC_MARK_LCORNERCURVE),
            (SC_MARKNUM_FOLDEREND, SC_MARK_BOXPLUSCONNECTED),
            (SC_MARKNUM_FOLDEROPENMID, SC_MARK_BOXMINUSCONNECTED),
            (SC_MARKNUM_FOLDERMIDTAIL, SC_MARK_TCORNERCURVE)
        ]
        for (num, mark) in markers {
            view.message(UInt32(SCI_MARKERDEFINE), wParam: UInt(num), lParam: Int(mark))
        }
    }

    func configureMultiSelection(view: ScintillaView) {
        view.message(SciMsg.setMultipleSelection, wParam: 1)
        view.message(SciMsg.setAdditionalSelectionTyping, wParam: 1)
        view.message(SciMsg.setAdditionalCaretsBlink, wParam: 1)
        view.message(SciMsg.setAdditionalCaretsVisible, wParam: 1)
    }

    func applyFont(view: ScintillaView, fontName: String, fontSize: Int) {
        fontName.withCString { cFont in
            _ = view.message(
                SciMsg.styleSetFont,
                wParam: UInt(STYLE_DEFAULT),
                lParam: Int(bitPattern: cFont)
            )
            _ = view.message(
                SciMsg.styleSetFont,
                wParam: UInt(STYLE_LINENUMBER),
                lParam: Int(bitPattern: cFont)
            )
        }
        _ = view.message(SciMsg.styleSetSize, wParam: UInt(STYLE_DEFAULT), lParam: fontSize)
        _ = view.message(
            SciMsg.styleSetSize,
            wParam: UInt(STYLE_LINENUMBER),
            lParam: max(9, fontSize - 1)
        )
    }

    func applyTheme(view: ScintillaView, theme: Theme) {
        let bgColor = theme.backgroundColor.scintillaColorRef
        let fgColor = theme.foregroundColor.scintillaColorRef

        view.message(SciMsg.styleSetBack, wParam: UInt(STYLE_DEFAULT), lParam: bgColor)
        view.message(SciMsg.styleSetFore, wParam: UInt(STYLE_DEFAULT), lParam: fgColor)
        view.message(SciMsg.styleClearAll)

        for slot in 0...127 {
            view.message(SciMsg.styleSetBack, wParam: UInt(slot), lParam: bgColor)
            view.message(SciMsg.styleSetFore, wParam: UInt(slot), lParam: fgColor)
        }

        applyMarginsAndCaretTheme(view: view, theme: theme, baseBgColor: bgColor)
        applySyntaxHighlightTheme(view: view, theme: theme)
    }

    func applyMarginsAndCaretTheme(
        view: ScintillaView,
        theme: Theme,
        baseBgColor: Int
    ) {
        let caretColor = theme.caretColor.scintillaColorRef
        let selBgColor = theme.selectionColor.scintillaColorRef
        let lineBgColor = theme.lineNumberBgColor.scintillaColorRef
        let lineFgColor = theme.lineNumberFgColor.scintillaColorRef
        let foldBgColor = theme.foldMarginBgColor.scintillaColorRef
        let foldMarker = theme.foldMarkerColor.scintillaColorRef

        view.message(SciMsg.styleSetBack, wParam: UInt(STYLE_LINENUMBER), lParam: lineBgColor)
        view.message(SciMsg.styleSetFore, wParam: UInt(STYLE_LINENUMBER), lParam: lineFgColor)
        view.message(SciMsg.setMarginBackN, wParam: 0, lParam: lineBgColor)
        view.message(SciMsg.setMarginBackN, wParam: 1, lParam: lineBgColor)
        view.message(SciMsg.setMarginBackN, wParam: 2, lParam: foldBgColor)

        view.message(SciMsg.setFoldMarginColour, wParam: 1, lParam: foldBgColor)
        view.message(SciMsg.setFoldMarginHiColour, wParam: 1, lParam: foldBgColor)

        view.message(SciMsg.setCaretFore, wParam: UInt(caretColor))
        view.message(SciMsg.setCaretPeriod, wParam: 500)
        view.message(SciMsg.setCaretLineVisible, wParam: 1)

        let caretLineBg = theme.isDark
            ? theme.backgroundColor.blended(withFraction: 0.10, of: .white)?.scintillaColorRef
                ?? baseBgColor
            : theme.backgroundColor.blended(withFraction: 0.05, of: .black)?.scintillaColorRef
                ?? baseBgColor
        view.message(SciMsg.setCaretLineBack, wParam: UInt(caretLineBg))
        view.message(SciMsg.setCaretLineBackAlpha, wParam: 60)

        view.message(SciMsg.setSelBack, wParam: 1, lParam: selBgColor)
        view.message(SciMsg.setSelFore, wParam: 0, lParam: 0)
        view.message(SciMsg.setAdditionalSelBack, wParam: UInt(selBgColor))
        view.message(SciMsg.setAdditionalSelFore, wParam: 0, lParam: 0)

        for marker in [
            SC_MARKNUM_FOLDEROPEN, SC_MARKNUM_FOLDER, SC_MARKNUM_FOLDERSUB,
            SC_MARKNUM_FOLDERTAIL, SC_MARKNUM_FOLDEREND, SC_MARKNUM_FOLDEROPENMID,
            SC_MARKNUM_FOLDERMIDTAIL
        ] {
            view.message(SciMsg.markerSetBack, wParam: UInt(marker), lParam: foldBgColor)
            view.message(SciMsg.markerSetFore, wParam: UInt(marker), lParam: foldMarker)
        }
    }

    func applySyntaxHighlightTheme(view: ScintillaView, theme: Theme) {
        let commentColor = theme.commentColor.scintillaColorRef
        let keywordColor = theme.keywordColor.scintillaColorRef
        let stringColor = theme.stringColor.scintillaColorRef
        let numberColor = theme.numberColor.scintillaColorRef
        let operColor = theme.operatorColor.scintillaColorRef
        let idenColor = theme.identifierColor.scintillaColorRef
        let prepColor = theme.preprocessorColor.scintillaColorRef
        let selBgColor = theme.selectionColor.scintillaColorRef

        for slot in [1, 2, 3, 15] {
            view.message(SciMsg.styleSetFore, wParam: UInt(slot), lParam: commentColor)
        }
        view.message(SciMsg.styleSetFore, wParam: 4, lParam: numberColor)
        view.message(SciMsg.styleSetFore, wParam: 5, lParam: keywordColor)
        for slot in [6, 7, 12] {
            view.message(SciMsg.styleSetFore, wParam: UInt(slot), lParam: stringColor)
        }
        view.message(SciMsg.styleSetFore, wParam: 9, lParam: prepColor)
        view.message(SciMsg.styleSetFore, wParam: 10, lParam: operColor)
        view.message(SciMsg.styleSetFore, wParam: 11, lParam: idenColor)

        view.message(SciMsg.styleSetFore, wParam: UInt(STYLE_BRACELIGHT), lParam: keywordColor)
        view.message(SciMsg.styleSetBack, wParam: UInt(STYLE_BRACELIGHT), lParam: selBgColor)
        view.message(SciMsg.styleSetFore, wParam: UInt(STYLE_BRACEBAD), lParam: 0x0000FF)
        view.message(SciMsg.styleSetBack, wParam: UInt(STYLE_BRACEBAD), lParam: selBgColor)
    }

    func applyLanguage(view: ScintillaView, language: LanguageDefinition) {
        language.lexerID.withCString { cLexer in
            ScintillaSetLexer(view, cLexer)
        }

        if !language.keywords.isEmpty {
            language.keywords.withCString { cKw in
                _ = view.message(
                    UInt32(SCI_SETKEYWORDS),
                    wParam: 0,
                    lParam: Int(bitPattern: cKw)
                )
            }
        }

        if language.isFoldable {
            setScintillaProperty(view: view, key: "fold", val: "1")
            setScintillaProperty(view: view, key: "fold.compact", val: "0")
            setScintillaProperty(view: view, key: "fold.comment", val: "1")
            setScintillaProperty(view: view, key: "fold.preprocessor", val: "1")
            setScintillaProperty(view: view, key: "fold.html", val: "1")
        }

        view.message(UInt32(4003), wParam: 0, lParam: -1) // SCI_COLOURISE
    }

    func setScintillaProperty(view: ScintillaView, key: String, val: String) {
        key.withCString { cProp in
            val.withCString { cVal in
                _ = view.message(
                    UInt32(SCI_SETPROPERTY),
                    wParam: UInt(bitPattern: cProp),
                    lParam: Int(bitPattern: cVal)
                )
            }
        }
    }

    func calculateLineMarginWidth(view: ScintillaView) -> Int {
        let lines = max(view.message(UInt32(SCI_GETLINECOUNT)), 1)
        let digits = String(lines).count
        return max(32, 16 + digits * 8)
    }
}
