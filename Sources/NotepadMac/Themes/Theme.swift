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

import AppKit
import SwiftUI

public struct Theme: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let isDark: Bool

    // Editor Scintilla Canvas Colors
    public let backgroundHex: String
    public let foregroundHex: String
    public let caretHex: String
    public let selectionHex: String
    public let lineNumberBgHex: String
    public let lineNumberFgHex: String
    public let foldMarginBgHex: String
    public let foldMarkerHex: String

    // Syntax Highlighting Tokens
    public let commentHex: String
    public let keywordHex: String
    public let stringHex: String
    public let numberHex: String
    public let operatorHex: String
    public let identifierHex: String
    public let preprocessorHex: String

    // Window & Chrome UI Colors
    public let windowBgHex: String
    public let tabBarBgHex: String
    public let activeTabBgHex: String
    public let statusBarBgHex: String
    public let borderHex: String

    public var backgroundColor: NSColor { NSColor(hex: backgroundHex) }
    public var foregroundColor: NSColor { NSColor(hex: foregroundHex) }
    public var caretColor: NSColor { NSColor(hex: caretHex) }
    public var selectionColor: NSColor { NSColor(hex: selectionHex) }
    public var lineNumberBgColor: NSColor { NSColor(hex: lineNumberBgHex) }
    public var lineNumberFgColor: NSColor { NSColor(hex: lineNumberFgHex) }
    public var foldMarginBgColor: NSColor { NSColor(hex: foldMarginBgHex) }
    public var foldMarkerColor: NSColor { NSColor(hex: foldMarkerHex) }

    public var commentColor: NSColor { NSColor(hex: commentHex) }
    public var keywordColor: NSColor { NSColor(hex: keywordHex) }
    public var stringColor: NSColor { NSColor(hex: stringHex) }
    public var numberColor: NSColor { NSColor(hex: numberHex) }
    public var operatorColor: NSColor { NSColor(hex: operatorHex) }
    public var identifierColor: NSColor { NSColor(hex: identifierHex) }
    public var preprocessorColor: NSColor { NSColor(hex: preprocessorHex) }

    public var windowBgColor: NSColor { NSColor(hex: windowBgHex) }
    public var tabBarBgColor: NSColor { NSColor(hex: tabBarBgHex) }
    public var activeTabBgColor: NSColor { NSColor(hex: activeTabBgHex) }
    public var statusBarBgColor: NSColor { NSColor(hex: statusBarBgHex) }
    public var borderColor: NSColor { NSColor(hex: borderHex) }

    // SwiftUI Color Accessors
    public var backgroundSwiftUIColor: Color { Color(hex: backgroundHex) }
    public var foregroundSwiftUIColor: Color { Color(hex: foregroundHex) }
    public var caretSwiftUIColor: Color { Color(hex: caretHex) }
    public var selectionSwiftUIColor: Color { Color(hex: selectionHex) }
    public var lineNumberBgSwiftUIColor: Color { Color(hex: lineNumberBgHex) }
    public var lineNumberFgSwiftUIColor: Color { Color(hex: lineNumberFgHex) }
    public var foldMarginBgSwiftUIColor: Color { Color(hex: foldMarginBgHex) }
    public var foldMarkerSwiftUIColor: Color { Color(hex: foldMarkerHex) }

    public var windowBgSwiftUIColor: Color { Color(hex: windowBgHex) }
    public var tabBarBgSwiftUIColor: Color { Color(hex: tabBarBgHex) }
    public var activeTabBgSwiftUIColor: Color { Color(hex: activeTabBgHex) }
    public var statusBarBgSwiftUIColor: Color { Color(hex: statusBarBgHex) }
    public var borderSwiftUIColor: Color { Color(hex: borderHex) }

    // MARK: - Predefined Themes

    public static let sparkNotepadLight = Theme(
        id: "spark-notepad-light",
        name: "SparkNotePad Light",
        isDark: false,
        backgroundHex: "#fafbfc",
        foregroundHex: "#24292f",
        caretHex: "#0969da",
        selectionHex: "#c8e1ff",
        lineNumberBgHex: "#f0f2f5",
        lineNumberFgHex: "#57606a",
        foldMarginBgHex: "#f0f2f5",
        foldMarkerHex: "#57606a",
        commentHex: "#57606a",
        keywordHex: "#0969da",
        stringHex: "#1a7f37",
        numberHex: "#0550ae",
        operatorHex: "#cf222e",
        identifierHex: "#0550ae",
        preprocessorHex: "#cf222e",
        windowBgHex: "#f0f2f5",
        tabBarBgHex: "#e1e4e8",
        activeTabBgHex: "#fafbfc",
        statusBarBgHex: "#f0f2f5",
        borderHex: "#d0d7de"
    )

    public static let sparkNotepadDark = Theme(
        id: "spark-notepad-dark",
        name: "SparkNotePad Dark",
        isDark: true,
        backgroundHex: "#1e1e2e",
        foregroundHex: "#cdd6f4",
        caretHex: "#89b4fa",
        selectionHex: "#313244",
        lineNumberBgHex: "#181825",
        lineNumberFgHex: "#6c7086",
        foldMarginBgHex: "#181825",
        foldMarkerHex: "#89b4fa",
        commentHex: "#6c7086",
        keywordHex: "#cba6f7",
        stringHex: "#a6e3a1",
        numberHex: "#fab387",
        operatorHex: "#89dceb",
        identifierHex: "#89b4fa",
        preprocessorHex: "#f38ba8",
        windowBgHex: "#11111b",
        tabBarBgHex: "#181825",
        activeTabBgHex: "#1e1e2e",
        statusBarBgHex: "#11111b",
        borderHex: "#313244"
    )

    public static let oneDarkPro = Theme(
        id: "one-dark-pro",
        name: "One Dark Pro",
        isDark: true,
        backgroundHex: "#282c34",
        foregroundHex: "#abb2bf",
        caretHex: "#528bff",
        selectionHex: "#3e4451",
        lineNumberBgHex: "#21252b",
        lineNumberFgHex: "#636d83",
        foldMarginBgHex: "#21252b",
        foldMarkerHex: "#abb2bf",
        commentHex: "#5c6370",
        keywordHex: "#c678dd",
        stringHex: "#98c379",
        numberHex: "#d19a66",
        operatorHex: "#56b6c2",
        identifierHex: "#e06c75",
        preprocessorHex: "#e5c07b",
        windowBgHex: "#1e2227",
        tabBarBgHex: "#181a1f",
        activeTabBgHex: "#282c34",
        statusBarBgHex: "#21252b",
        borderHex: "#3e4451"
    )

    public static let dracula = Theme(
        id: "dracula",
        name: "Dracula",
        isDark: true,
        backgroundHex: "#282a36",
        foregroundHex: "#f8f8f2",
        caretHex: "#ae81ff",
        selectionHex: "#44475a",
        lineNumberBgHex: "#1e1f29",
        lineNumberFgHex: "#6272a4",
        foldMarginBgHex: "#1e1f29",
        foldMarkerHex: "#bd93f9",
        commentHex: "#6272a4",
        keywordHex: "#ff79c6",
        stringHex: "#f1fa8c",
        numberHex: "#bd93f9",
        operatorHex: "#ff79c6",
        identifierHex: "#50fa7b",
        preprocessorHex: "#ffb86c",
        windowBgHex: "#1e1f29",
        tabBarBgHex: "#191a21",
        activeTabBgHex: "#282a36",
        statusBarBgHex: "#1e1f29",
        borderHex: "#44475a"
    )

    public static let monokai = Theme(
        id: "monokai",
        name: "Monokai",
        isDark: true,
        backgroundHex: "#272822",
        foregroundHex: "#f8f8f2",
        caretHex: "#f8f8f0",
        selectionHex: "#49483e",
        lineNumberBgHex: "#1e1f1c",
        lineNumberFgHex: "#75715e",
        foldMarginBgHex: "#1e1f1c",
        foldMarkerHex: "#a6e22e",
        commentHex: "#75715e",
        keywordHex: "#f92672",
        stringHex: "#e6db74",
        numberHex: "#ae81ff",
        operatorHex: "#f92672",
        identifierHex: "#a6e22e",
        preprocessorHex: "#66d9ef",
        windowBgHex: "#1e1f1c",
        tabBarBgHex: "#171815",
        activeTabBgHex: "#272822",
        statusBarBgHex: "#1e1f1c",
        borderHex: "#3e3d32"
    )

    public static let gitHubLight = Theme(
        id: "github-light",
        name: "GitHub Light",
        isDark: false,
        backgroundHex: "#ffffff",
        foregroundHex: "#24292e",
        caretHex: "#044289",
        selectionHex: "#c8e1ff",
        lineNumberBgHex: "#f6f8fa",
        lineNumberFgHex: "#959da5",
        foldMarginBgHex: "#f6f8fa",
        foldMarkerHex: "#586069",
        commentHex: "#6a737d",
        keywordHex: "#d73a49",
        stringHex: "#032f62",
        numberHex: "#005cc5",
        operatorHex: "#d73a49",
        identifierHex: "#6f42c1",
        preprocessorHex: "#e36209",
        windowBgHex: "#f6f8fa",
        tabBarBgHex: "#ebedf0",
        activeTabBgHex: "#ffffff",
        statusBarBgHex: "#f6f8fa",
        borderHex: "#d0d7de"
    )

    public static let solarizedLight = Theme(
        id: "solarized-light",
        name: "Solarized Light",
        isDark: false,
        backgroundHex: "#fdf6e3",
        foregroundHex: "#657b83",
        caretHex: "#268bd2",
        selectionHex: "#eee8d5",
        lineNumberBgHex: "#eee8d5",
        lineNumberFgHex: "#93a1a1",
        foldMarginBgHex: "#eee8d5",
        foldMarkerHex: "#586e75",
        commentHex: "#93a1a1",
        keywordHex: "#859900",
        stringHex: "#2aa198",
        numberHex: "#d33682",
        operatorHex: "#b58900",
        identifierHex: "#268bd2",
        preprocessorHex: "#cb4b16",
        windowBgHex: "#eee8d5",
        tabBarBgHex: "#e0d9c4",
        activeTabBgHex: "#fdf6e3",
        statusBarBgHex: "#eee8d5",
        borderHex: "#93a1a1"
    )

    public static let catppuccinMocha = Theme(
        id: "catppuccin-mocha",
        name: "Catppuccin Mocha",
        isDark: true,
        backgroundHex: "#1e1e2e",
        foregroundHex: "#cdd6f4",
        caretHex: "#89b4fa",
        selectionHex: "#313244",
        lineNumberBgHex: "#11111b",
        lineNumberFgHex: "#a6adc8",
        foldMarginBgHex: "#11111b",
        foldMarkerHex: "#89b4fa",
        commentHex: "#a6adc8",
        keywordHex: "#74c7ec",
        stringHex: "#a6e3a1",
        numberHex: "#cba6f7",
        operatorHex: "#6c7086",
        identifierHex: "#89b4fa",
        preprocessorHex: "#74c7ec",
        windowBgHex: "#11111b",
        tabBarBgHex: "#181825",
        activeTabBgHex: "#1e1e2e",
        statusBarBgHex: "#11111b",
        borderHex: "#313244"
    )

    public static let catppuccinLatte = Theme(
        id: "catppuccin-latte",
        name: "Catppuccin Latte",
        isDark: false,
        backgroundHex: "#eff1f5",
        foregroundHex: "#4c4f69",
        caretHex: "#1e66f5",
        selectionHex: "#bcc0cc",
        lineNumberBgHex: "#dce0e8",
        lineNumberFgHex: "#6c6f85",
        foldMarginBgHex: "#dce0e8",
        foldMarkerHex: "#1e66f5",
        commentHex: "#6c6f85",
        keywordHex: "#1e66f5",
        stringHex: "#40a02b",
        numberHex: "#8839ef",
        operatorHex: "#9ca0b0",
        identifierHex: "#1e66f5",
        preprocessorHex: "#209fb5",
        windowBgHex: "#dce0e8",
        tabBarBgHex: "#e6e9ef",
        activeTabBgHex: "#eff1f5",
        statusBarBgHex: "#dce0e8",
        borderHex: "#ccd0da"
    )

    public static let tokyoNight = Theme(
        id: "tokyo-night",
        name: "Tokyo Night",
        isDark: true,
        backgroundHex: "#1a1b26",
        foregroundHex: "#c0caf5",
        caretHex: "#7aa2f7",
        selectionHex: "#283457",
        lineNumberBgHex: "#16161e",
        lineNumberFgHex: "#565f89",
        foldMarginBgHex: "#16161e",
        foldMarkerHex: "#7dcfff",
        commentHex: "#565f89",
        keywordHex: "#7dcfff",
        stringHex: "#9ece6a",
        numberHex: "#bb9af7",
        operatorHex: "#565f89",
        identifierHex: "#7aa2f7",
        preprocessorHex: "#2ac3de",
        windowBgHex: "#16161e",
        tabBarBgHex: "#16161e",
        activeTabBgHex: "#1a1b26",
        statusBarBgHex: "#16161e",
        borderHex: "#2f334d"
    )

    public static let nordDark = Theme(
        id: "nord-dark",
        name: "Nord Dark",
        isDark: true,
        backgroundHex: "#2e3440",
        foregroundHex: "#d8dee9",
        caretHex: "#88c0d0",
        selectionHex: "#434c5e",
        lineNumberBgHex: "#242933",
        lineNumberFgHex: "#4c566a",
        foldMarginBgHex: "#242933",
        foldMarkerHex: "#88c0d0",
        commentHex: "#4c566a",
        keywordHex: "#88c0d0",
        stringHex: "#a3be8c",
        numberHex: "#b48ead",
        operatorHex: "#4c566a",
        identifierHex: "#81a1c1",
        preprocessorHex: "#8fbcbb",
        windowBgHex: "#242933",
        tabBarBgHex: "#242933",
        activeTabBgHex: "#2e3440",
        statusBarBgHex: "#242933",
        borderHex: "#3b4252"
    )

    public static let gruvboxDark = Theme(
        id: "gruvbox-dark",
        name: "Gruvbox Dark",
        isDark: true,
        backgroundHex: "#282828",
        foregroundHex: "#ebdbb2",
        caretHex: "#ebdbb2",
        selectionHex: "#504945",
        lineNumberBgHex: "#1d2021",
        lineNumberFgHex: "#928374",
        foldMarginBgHex: "#1d2021",
        foldMarkerHex: "#ebdbb2",
        commentHex: "#928374",
        keywordHex: "#83a598",
        stringHex: "#b8bb26",
        numberHex: "#d3869b",
        operatorHex: "#928374",
        identifierHex: "#458588",
        preprocessorHex: "#8ec07c",
        windowBgHex: "#1d2021",
        tabBarBgHex: "#1d2021",
        activeTabBgHex: "#282828",
        statusBarBgHex: "#1d2021",
        borderHex: "#3c3836"
    )

    public static let gitHubDark = Theme(
        id: "github-dark",
        name: "GitHub Dark",
        isDark: true,
        backgroundHex: "#0d1117",
        foregroundHex: "#c9d1d9",
        caretHex: "#58a6ff",
        selectionHex: "#163b65",
        lineNumberBgHex: "#090d13",
        lineNumberFgHex: "#8b949e",
        foldMarginBgHex: "#090d13",
        foldMarkerHex: "#58a6ff",
        commentHex: "#8b949e",
        keywordHex: "#ff7b72",
        stringHex: "#a5d6ff",
        numberHex: "#79c0ff",
        operatorHex: "#ff7b72",
        identifierHex: "#d2a8ff",
        preprocessorHex: "#ffa657",
        windowBgHex: "#090d13",
        tabBarBgHex: "#090d13",
        activeTabBgHex: "#0d1117",
        statusBarBgHex: "#090d13",
        borderHex: "#30363d"
    )

    public static let solarizedDark = Theme(
        id: "solarized-dark",
        name: "Solarized Dark",
        isDark: true,
        backgroundHex: "#002b36",
        foregroundHex: "#839496",
        caretHex: "#268bd2",
        selectionHex: "#073642",
        lineNumberBgHex: "#00212b",
        lineNumberFgHex: "#586e75",
        foldMarginBgHex: "#00212b",
        foldMarkerHex: "#268bd2",
        commentHex: "#586e75",
        keywordHex: "#859900",
        stringHex: "#2aa198",
        numberHex: "#d33682",
        operatorHex: "#b58900",
        identifierHex: "#268bd2",
        preprocessorHex: "#cb4b16",
        windowBgHex: "#00212b",
        tabBarBgHex: "#00212b",
        activeTabBgHex: "#002b36",
        statusBarBgHex: "#00212b",
        borderHex: "#073642"
    )

    public static let ayuDark = Theme(
        id: "ayu-dark",
        name: "Ayu Dark",
        isDark: true,
        backgroundHex: "#0f1419",
        foregroundHex: "#e6e1cf",
        caretHex: "#e6b450",
        selectionHex: "#253340",
        lineNumberBgHex: "#0b0e14",
        lineNumberFgHex: "#4b5666",
        foldMarginBgHex: "#0b0e14",
        foldMarkerHex: "#39bae6",
        commentHex: "#5c6773",
        keywordHex: "#ff8f40",
        stringHex: "#aad94c",
        numberHex: "#d2a6ff",
        operatorHex: "#f29668",
        identifierHex: "#39bae6",
        preprocessorHex: "#e6b450",
        windowBgHex: "#0b0e14",
        tabBarBgHex: "#0b0e14",
        activeTabBgHex: "#0f1419",
        statusBarBgHex: "#0b0e14",
        borderHex: "#1e2530"
    )

    public static let allThemes: [Theme] = [
        .sparkNotepadLight,
        .sparkNotepadDark,
        .catppuccinMocha,
        .catppuccinLatte,
        .tokyoNight,
        .nordDark,
        .gruvboxDark,
        .gitHubDark,
        .gitHubLight,
        .oneDarkPro,
        .dracula,
        .monokai,
        .solarizedDark,
        .solarizedLight,
        .ayuDark
    ]
}

extension Color {
    public init(hex: String) {
        self.init(NSColor(hex: hex))
    }

    /// Formats Color into standard #RRGGBB uppercase hex string
    public func toHex() -> String {
        NSColor(self).toHex()
    }
}

public struct ProminentButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            )
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(configuration.isPressed ? Color.primary.opacity(0.15) : Color.primary.opacity(0.08))
            )
    }
}

extension NSColor {
    convenience init(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleanHex.hasPrefix("#") {
            cleanHex.remove(at: cleanHex.startIndex)
        }

        let scanner = Scanner(string: cleanHex)
        var rgbValue: UInt64 = 0
        let scanned = scanner.scanHexInt64(&rgbValue)
        let isValid = scanned && scanner.isAtEnd

        let redVal, greenVal, blueVal, alphaVal: CGFloat
        if isValid && cleanHex.count == 6 {
            redVal = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            greenVal = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            blueVal = CGFloat(rgbValue & 0x0000FF) / 255.0
            alphaVal = 1.0
        } else if isValid && cleanHex.count == 8 {
            redVal = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            greenVal = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            blueVal = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            alphaVal = CGFloat(rgbValue & 0x000000FF) / 255.0
        } else {
            redVal = 0.5
            greenVal = 0.5
            blueVal = 0.5
            alphaVal = 1.0
        }

        self.init(red: redVal, green: greenVal, blue: blueVal, alpha: alphaVal)
    }

    /// Formats NSColor into standard #RRGGBB uppercase hex string
    public func toHex() -> String {
        guard let rgb = usingColorSpace(.sRGB) else { return "#808080" }
        let redInt = Int(round(rgb.redComponent * 255.0))
        let greenInt = Int(round(rgb.greenComponent * 255.0))
        let blueInt = Int(round(rgb.blueComponent * 255.0))
        return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
    }

    /// Converts NSColor to BGR integer representation expected by Scintilla
    public var scintillaColorRef: Int {
        guard let rgb = usingColorSpace(.sRGB) else { return 0 }
        let red = Int(rgb.redComponent * 255)
        let green = Int(rgb.greenComponent * 255)
        let blue = Int(rgb.blueComponent * 255)
        return (blue << 16) | (green << 8) | red
    }
}
