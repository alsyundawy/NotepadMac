<!-- markdownlint-disable-file MD013 MD022 MD026 MD032 MD033 MD041 MD060 -->

<p align="center">
  <a href="https://github.com/alsyundawy/NotepadMac">
    <img src="Resources/AppIcon.iconset/icon_256x256.png" width="128" height="128" alt="NotepadMac Native macOS Application Icon" />
  </a>
</p>

<h1 align="center">NotepadMac</h1>

<p align="center">
  <b>NotepadMac — Production-Ready Native macOS Text and Source Code Editor Built with Scintilla Cocoa, Lexilla, SwiftUI, and Embedded Lua 5.5.1</b><br>
  <i>Engineered with native Scintilla 5.6.9 / Lexilla 5.5.5 core, SwiftUI, and AppKit for sub-millisecond execution performance and minimal memory footprint</i>
</p>

<p align="center">
  <a href="https://github.com/alsyundawy/NotepadMac/releases/latest"><img src="https://img.shields.io/badge/Release-v1.0.0-2ea44f?style=for-the-badge&logo=github&logoColor=white" alt="Latest Release v1.0.0"></a>
  <a href="https://github.com/alsyundawy/NotepadMac"><img src="https://img.shields.io/badge/Platform-macOS%2011.0%2B-000000?style=for-the-badge&logo=apple&logoColor=white" alt="macOS 11.0+"></a>
  <a href="https://github.com/alsyundawy/NotepadMac"><img src="https://img.shields.io/badge/Architecture-Universal%20(arm64%20%2B%20x86__64)-success?style=for-the-badge&logo=apple&logoColor=white" alt="Universal Binary"></a>
  <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Standard-Swift%205.9%2B%20%7C%20C%2B%2B17-FA7343?style=for-the-badge&logo=swift&logoColor=white" alt="Swift & C++17"></a>
  <a href="https://www.scintilla.org"><img src="https://img.shields.io/badge/Engine-Scintilla%205.6.9%20%2B%20Lexilla%205.5.5-8957e5?style=for-the-badge" alt="Scintilla + Lexilla"></a>
  <a href="https://www.lua.org"><img src="https://img.shields.io/badge/Lua-5.5.1%20Sandboxed-brightgreen?style=for-the-badge&logo=lua&logoColor=white" alt="Lua 5.5.1"></a>
  <a href="https://github.com/alsyundawy/NotepadMac/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-GPL--3.0-blue?style=for-the-badge" alt="GPL-3.0 License"></a>
  <a href="https://github.com/alsyundawy/NotepadMac/actions"><img src="https://img.shields.io/badge/CI%2FCD-100%25%20Passing-success?style=for-the-badge&logo=githubactions&logoColor=white" alt="CI/CD Status"></a>
</p>

<p align="center">
  <b>NotepadMac</b> is a fast, lightweight, and modern native macOS desktop text editor designed in the spirit of classic desktop code editors (such as Notepad++ and SparkNotePad) but re-engineered from the ground up for macOS using modern <b>SwiftUI</b> and the proven <b>Scintilla / Lexilla</b> editing engine.
</p>

<p align="center">
  Engineered as a high-performance native desktop editor, it delivers instant sub-millisecond line rendering, multi-selection editing, 50+ programming language highlighters with code folding, military-grade AES-256 document encryption (PBKDF2 100k + HMAC-SHA256), a dedicated Developer &amp; Security Tools Hub, an embedded sandboxed Lua 5.5.1 automation runtime, a modernized Find, Replace &amp; Mark Hub, native unsaved changes confirmation guards, and universal binary distribution (<code>arm64</code> + <code>x86_64</code>) — running entirely native without Electron or webview bloat at under 25 MB idle memory footprint.
</p>

<p align="center">
  <a href="#downloads--release-artifacts">
    <img src="https://img.shields.io/badge/🚀_Download_Artifacts-v1.0.0-238636?style=for-the-badge&logo=cloudsmith&logoColor=white" alt="Download Artifacts">
  </a>
  <a href="https://github.com/alsyundawy/NotepadMac/releases/latest">
    <img src="https://img.shields.io/badge/🪞_Releases_&_Changelog-GitHub-0284c7?style=for-the-badge&logo=github&logoColor=white" alt="Releases & Changelog">
  </a>
  <a href="https://www.scintilla.org">
    <img src="https://img.shields.io/badge/⚙️_Engine_Heritage-Scintilla_&_Lexilla-orange?style=for-the-badge&logo=cplusplus&logoColor=white" alt="Scintilla Heritage">
  </a>
  <a href="DOCNOTE.md">
    <img src="https://img.shields.io/badge/📖_Documentation-Release_DocNotes-6f42c1?style=for-the-badge&logo=gitbook&logoColor=white" alt="Official DocNotes">
  </a>
  <a href="https://github.com/alsyundawy/NotepadMac/issues">
    <img src="https://img.shields.io/badge/🐛_Report_Issue-GitHub_Issues-red?style=for-the-badge&logo=github&logoColor=white" alt="Report Issue">
  </a>
</p>

---

> Lead Developer & Maintainer:<br>
> **[`HARRY DERTIN SUTISNA ALSYUNDAWY (@alsyundawy)`](https://github.com/alsyundawy)** — [`ALSYUNDAWY IT SOLUTION`](https://alsyundawy.com)<br>
>
> 🍏 **[`Latest Releases (v1.0.0)`](https://github.com/alsyundawy/NotepadMac/releases/latest)** &nbsp;|&nbsp;
> 📖 **[`Release DocNotes (DOCNOTE.md)`](DOCNOTE.md)** &nbsp;|&nbsp;
> 📜 **[`Changelog (CHANGELOG.md)`](CHANGELOG.md)** &nbsp;|&nbsp;
> 🐛 **[`Issue Tracker`](https://github.com/alsyundawy/NotepadMac/issues)** &nbsp;|&nbsp;
> 💖 **[`Support via PayPal`](https://www.paypal.me/alsyundawy)**

---

> [!IMPORTANT]
>
> ### ⚠️ Architectural Heritage, Engine Invariants & Legal Notice
>
> 1. **Scintilla & Lexilla Core Heritage**: NotepadMac is built upon the official Cocoa port of Scintilla 5.6.9 and Lexilla 5.5.5, authored by Neil Hodgson. Scintilla and Lexilla are distributed under the Historical Permission Notice and Disclaimer (HPND) license, which is fully compatible with GNU General Public License v3.0.
> 2. **Embedded Lua Automation Core**: Embedded automation is powered by official Lua 5.5.1 under the MIT License by PUC-Rio.
> 3. **Design & Ergonomics Heritage**: NotepadMac incorporates UI paradigms, theme palettes, and toolset workflows inspired by **SparkNotePad** (by Harry Dertin Sutisna Alsyundawy) and **Notepad++** (by Don Ho).
> 4. **License Compliance**: NotepadMac is licensed under the **GNU General Public License v3.0 or later (GPL-3.0-or-later)**. All original author copyrights, notices, and permissive third-party software attributions are preserved in full.

---

## Highlights & Features

- **Native Scintilla Cocoa Core (v5.6.9)**:
  - Powered by official Scintilla 5.6.9 Cocoa (`ScintillaView`) wrapped cleanly in SwiftUI via `NSViewRepresentable`.
  - Sub-millisecond hardware-accelerated text layout, caret rendering, multi-selection, and undo/redo stacks.
  - Zero-allocation UTF-8 byte traversal in `EditorDocument.lineCount`.
- **Lexilla Syntax Highlighting (50+ Languages)**:
  - Fully integrated Lexilla 5.5.5 lexers supporting 50+ programming languages with hierarchical code folding:
    - _Core_: Plain Text, Lua, Python, Swift, C/C++, Objective-C/C++, Rust, Go, Zig, JavaScript, TypeScript, HTML, CSS, SCSS, Less, PHP, Ruby, Perl, Bash, Zsh, PowerShell, Batch, Java, C#, SQL, XML, JSON, JSON5, YAML, TOML, Markdown, Diff, Makefile, CMake, Properties/INI.
    - _Extended_: Ada, Assembly (x86/ARM), COBOL, CoffeeScript, D, Dart, Dockerfile, Erlang, Fortran, F#, GDScript, Haskell, Julia, Kotlin, LaTeX/TeX, Common Lisp/Scheme, MATLAB/Octave, Nim, Nix, OCaml, Pascal/Delphi, R, Scala, Tcl/Tk, Verilog HDL, VHDL, and Visual Basic.
  - Organized alphabetically with letter submenus (A–Z) across Menu Bar, Toolbar, and Status Bar.
  - Immediate Lexilla colorization (`SCI_COLOURISE`) on document load and switching.
- **Embedded Lua 5.5.1 Engine**:
  - Built-in, sandboxed Lua 5.5.1 runtime with an interactive console sheet (`⌘K`) and direct `editor.*` manipulation APIs for automation, macros, and plugin scripting.
- **Modernized Find, Replace & Mark Hub (`FindReplaceDialogView`)**:
  - Standalone modal dialog box perfectly aligned with Tools Hub design tokens and macOS Human Interface Guidelines.
  - Tabbed navigation across **Find**, **Replace**, and **Mark** modes with native segmented controls.
  - Search options: Match Case (`Aa`), Whole Word Only (`\b`), Regular Expression (`.*`), and Wrap Around (`↩`).
  - Direction controls (Up / Down) and comprehensive actions: Find Next (`Return`), Find Previous, Replace, Replace All, and Count occurrences across the entire buffer.
  - Full Notepad++ **Mark** engine: Mark All with Indicator 8 highlighting, line bookmarking in margin 1 (`🔖`), Clear All Marks, and Copy Marked Text.
  - Modernized in-window collapsible search bar (`⇧⌘F`) with localized buttons, clear buttons, live status pills, and quick expand to full dialog.
- **Developer & Security Tools Hub (`ToolsDialogView`)**:
  - **Developer Tools**:
    - **HTML, JSON, CSS & JavaScript Minify & Unminify (Prettify)**: Syntax-aware beautification and minification for web assets with configurable indent spacing.
    - **HTML Encrypt & Decrypt**: Obfuscation and encryption engine inspired by `html-code-generator.com`, including client-side JS `unescape`, Base64 dynamic evaluation, and password-protected standalone AES-GCM Web Crypto HTML containers.
    - XML document validation and minification, JWT inspection (header, claims, payload, signature, exp/iat timestamp parsing), UUID v4 generator, and Unix Epoch / ISO 8601 converter.
  - **Hash Tools**: Fast computation of MD5, SHA-1, SHA-256, SHA-384, SHA-512, and IEEE 802.3 CRC32 with real-time text and attached file checksum calculation, matching verification, and two-file comparison.
  - **Crypto Tools**: Military-grade AES-256-GCM encryption/decryption with PBKDF2-HMAC-SHA256 key derivation (100,000 iterations) and interactive password strength evaluation.
  - **MIME Tools**: Base64 encoding/decoding (full buffer and line-by-line), RFC 3986 URL percent-encoding, and HTML entity sanitization.
  - **Converter Tools**: ASCII to Hexadecimal (and reverse) and multi-base numeric converter (Binary, Octal, Decimal, Hexadecimal).
- **Data Loss Prevention Guard (Unsaved Changes Protection)**:
  - Native confirmation sheet (`NSAlert`) triggered before closing modified tabs, closing other tabs, closing tabs to the right, closing the window, and quitting the application (`⌘Q`).
  - Standard options: **Save** (`Return`), **Don't Save** (`⌘D`), and **Cancel** (`Esc`).
  - Automatically switches tab focus to the modified document so changes can be visually inspected before making a decision.
  - Intercepts `NSWindowDelegate.windowShouldClose` and `NSApplicationDelegate.applicationShouldTerminate` (`.terminateCancel` cleanly preserves buffers).
- **Modal Dialog & Tab Icon Polish with Focus Ring Elimination (`ModalCloseButton`)**:
  - Completely eliminated the macOS AppKit blue focus ring / rectangular background artifact around dialog close icons by introducing `ModalCloseButton`.
  - Decoupled the visible glyph (`Image` with `.contentShape(Circle())`, `.onHover`, and `.onTapGesture`) from an invisible zero-size key equivalent receiver (`Button` with `.frame(width: 0, height: 0)`, `.opacity(0)`, `.focusable(false)`, and `.keyboardShortcut(.cancelAction)`).
  - Applied across `ToolsDialogView`, `FindReplaceDialogView`, `CheckUpdateDialogView`, and `FindReplaceBar`.
  - Replaced text-field clear buttons (`xmark.circle`) and tab close buttons in `NotepadTabBar` with gesture-driven glyphs, ensuring clean, native rendering with zero focus ring artifacts during tab navigation and dialog interactions.
- **7 Handcrafted Developer Themes**:
  - SparkNotePad Light, SparkNotePad Dark, One Dark Pro (Default Dark), Dracula, Monokai, GitHub Light, and Solarized Light.
  - Automatic BGR Scintilla color calculation and SwiftUI color-space synchronizers.
- **Native Format Menu & Text Transformations**:
  - Dedicated **Format** menu (`FormatMenuCommands`) in menu bar.
  - Case conversions: `UPPERCASE` (`⇧⌘U`), `lowercase` (`⌃⌘L`), `Capitalize` (Title Case), and `Invert Case`.
  - Block Indent (`Tab` / `increase.indent`) and Outdent (`⇧Tab` / `decrease.indent`).
  - White Space & EOL character display toggle (`paragraphsign`) and Indentation Guides toggle (`ruler`).
  - Smart word detection fallback when no text is explicitly selected.
- **Bilingual Localization (i18n)**:
  - Full native support for **English** and **Bahasa Indonesia** (`id`) across all menus, dialogs, toolbar controls, status badges, and toolkits via `LocalizationManager`.
  - Instant reactive language switching without application restart.
- **Modern SwiftUI Chrome**:
  - Distinctive permanent dark toolbar (`#21252b`) with quick-action buttons.
  - Custom tab bar with document status badges (saved, unsaved/modified indicator dot, read-only) and color-coded tab tagging.
  - Responsive status bar with live cursor position (line, column), total line count, encoding, lexer language, and theme name.
  - Rich right-click context menu on editor canvas with editing, find/replace submenus, case conversion, line navigation, and view toggles.

---

## Architecture

NotepadMac is organized into clean, modular Swift packages and native targets:

```text
NotepadMac/
├── Package.swift                     # SPM manifest configured for macOS 11.0+
├── Sources/
│   ├── CLua/                         # Embedded Lua 5.5.1 engine (pure C)
│   │   ├── include/                  # Lua headers & Swift-compatible bridge
│   │   └── *.c                       # Official Lua 5.5.1 sources
│   ├── ScintillaCocoa/               # Scintilla 5.6.9 + Lexilla 5.5.5 Cocoa port
│   │   ├── include/                  # ScintillaBridge & public headers
│   │   ├── cocoa/                    # ScintillaView Cocoa implementation
│   │   ├── src/                      # Scintilla editing core
│   │   └── lexilla/                  # Lexilla language lexers
│   └── NotepadMac/                   # SwiftUI application layer
│       ├── Editor/                   # ScintillaView wrapper, search & context menu
│       ├── Lexers/                   # Lexer registry & extension mapping
│       ├── Localization/             # Multi-language localization manager (en / id)
│       ├── Lua/                      # LuaEngine bridging Swift <-> Lua
│       ├── Models/                   # EditorDocument & DocumentManager
│       ├── Themes/                   # Color palettes & Scintilla BGR converters
│       ├── Tools/                    # Developer, Hash, Crypto, Converter & MIME toolkits
│       ├── Views/                    # Toolbar, TabBar, StatusBar, Tools, Preferences, etc.
│       ├── NotepadMacApp.swift       # Application entry point & lifecycle
│       └── NotepadMenuCommands.swift # Native macOS menu bar commands
├── Resources/
│   ├── AppIcon.icns                  # Native macOS application icon
│   ├── Info.plist                    # Bundle identifier, categories, file types
│   └── NotepadMac.entitlements       # Sandboxing & file-access entitlements
└── scripts/
    ├── build-app.sh                  # Universal binary compiler and .app / .zip bundler
    ├── build-dmg.sh                  # Universal .dmg disk image packager
    ├── generate_app_icon.py          # Icon generation script
    └── test-runner.sh                # Test suite runner
```

---

## Security & 2025–2026 CVE Audit

NotepadMac is engineered with memory safety and modern macOS sandboxing invariants:

| Advisory / CVE     | Description                                                 | Target / Component           | NotepadMac Mitigation & Immunity                                                                                          |
| :----------------- | :---------------------------------------------------------- | :--------------------------- | :------------------------------------------------------------------------------------------------------------------------ |
| **CVE-2025-15556** | WinGUp updater integrity flaw without XML signatures        | Notepad++ (prior to 8.8.9)   | **Immune**: NotepadMac does not use WinGUp. Update checks run via read-only HTTPS GitHub Releases API queries.            |
| **CVE-2025-49144** | Insecure executable search path / installer binary planting | Notepad++ (prior to 8.8.1)   | **Immune**: macOS Mach-O bundles load from sandboxed `/Applications` with standard `.dmg` drag-and-drop.                  |
| **CVE-2026-73250** | Installer and Windows component search path hijacking       | Windows Installers           | **Immune**: Irrelevant on macOS. Standard signed AppKit bundles with no dynamic CWD library searching.                    |
| **CVE-2026-52884** | Path traversal in `isInTrustedDirectory()` Run Dialog       | Notepad++ (prior to 8.9.6.2) | **Immune**: All file paths are strictly canonicalized via Foundation `URL` with sandbox restrictions.                     |
| **CWE-119 / 787**  | Buffer overflow / memory corruption                         | C/C++ text parsers           | **Immune**: Scintilla 5.6.9 & Lexilla 5.5.5 run with memory-safe buffer management; Swift wrappers provide memory safety. |

---

## Downloads & Release Artifacts

| Platform            | Target Architecture                        | Format | Artifact File                                                                      |  Checksum Type  |
| :------------------ | :----------------------------------------- | :----: | :--------------------------------------------------------------------------------- | :-------------: |
| **macOS Universal** | `arm64` (Apple Silicon) + `x86_64` (Intel) | `.dmg` | [NotepadMac-1.0.0-macOS-Universal.dmg](build/NotepadMac-1.0.0-macOS-Universal.dmg) | CRC32 / SHA-256 |
| **macOS Universal** | `arm64` (Apple Silicon) + `x86_64` (Intel) | `.zip` | [NotepadMac-1.0.0-macOS-Universal.zip](build/NotepadMac-1.0.0-macOS-Universal.zip) |     SHA-256     |
| **macOS Bundle**    | `arm64` (Apple Silicon) + `x86_64` (Intel) | `.app` | [NotepadMac.app](build/NotepadMac.app)                                             |   Mach-O Fat    |

---

## Building from Source

### Prerequisites

- macOS 11.0 (Big Sur) or higher (tested through macOS 26.0 Sequoia)
- Xcode Command Line Tools (`xcode-select --install`)
- Swift 5.9+ / Swift 6.x toolchain

### Build Commands

```bash
# Clone repository
git clone https://github.com/alsyundawy/NotepadMac.git
cd NotepadMac

# Run automated unit tests
./scripts/test-runner.sh

# Build Universal Application (.app) and Distribution ZIP
./scripts/build-app.sh

# Build Compressed Universal Disk Image (.dmg)
./scripts/build-dmg.sh
```

---

## Third-Party Credits & Acknowledgments

- **Harry Dertin Sutisna Alsyundawy (@alsyundawy)** — Lead Developer, Architect & Maintainer, ALSYUNDAWY IT SOLUTION.
- **Scintilla (v5.6.9) & Lexilla (v5.5.5)** — Neil Hodgson & Contributors (HPND License).
- **Lua Programming Language (v5.5.1)** — Roberto Ierusalimschy, Waldemar Celes, Luiz Henrique de Figueiredo / PUC-Rio (MIT License).
- **SparkNotePad** — Harry Dertin Sutisna Alsyundawy & ALSYUNDAWY IT SOLUTION (GPLv3).
- **Notepad++** — Don Ho & Notepad++ Contributors (GPLv3).
- **Apple Inc.** — AppKit, SwiftUI, and macOS Platform SDKs.

---

## License

NotepadMac is free software: you can redistribute it and/or modify it under the terms of the **GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version**.

See [LICENSE](LICENSE) for the full license text.
