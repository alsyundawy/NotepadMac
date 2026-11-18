# NotepadMac

<!-- markdownlint-disable MD033 -->
<p align="center">
  <img src="Resources/AppIcon.iconset/icon_256x256.png" alt="NotepadMac Icon" width="128" height="128">
</p>

<h3 align="center">Production-Ready Native macOS Text Editor</h3>

<p align="center">
  <b>Built with Scintilla Cocoa, Lexilla, SwiftUI, and Embedded Lua 5.5.1</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2011.0%2B-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Architecture-Universal%20(arm64%20%2B%20x86__64)-success.svg" alt="Architecture">
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange.svg" alt="Swift">
  <img src="https://img.shields.io/badge/Scintilla-5.6.9-purple.svg" alt="Scintilla">
  <img src="https://img.shields.io/badge/Lexilla-5.5.5-teal.svg" alt="Lexilla">
  <img src="https://img.shields.io/badge/Lua-5.5.1-brightgreen.svg" alt="Lua">
  <img src="https://img.shields.io/badge/License-GPLv3-blue.svg" alt="License">
</p>
<!-- markdownlint-enable MD033 -->

---

## Overview

**NotepadMac** is a fast, lightweight, and modern native macOS text editor designed in the spirit of classic desktop code editors (such as Notepad++) but re-engineered from the ground up for macOS using modern **SwiftUI** and the proven **Scintilla / Lexilla** editing engine.

Unlike heavy Electron-based or web-wrapper text editors, NotepadMac starts instantaneously, runs with minimal memory footprint, and provides complete native macOS integration: AppKit menus, custom tabs, keyboard shortcuts, deep system font rendering, and universal binary distribution (`arm64` + `x86_64`).

---

## Highlights & Features

- **Native Scintilla Cocoa Core**: Powered by official Scintilla 5.6.9 Cocoa (`ScintillaView`) wrapped cleanly in SwiftUI via `NSViewRepresentable`.
- **Lexilla Syntax Highlighting (50+ Languages)**: Fully integrated Lexilla 5.5.5 lexers supporting:
  - Plain Text, Lua, Python, Swift, C/C++, Objective-C/C++, Rust, Go, Zig, JavaScript/TypeScript,
    HTML, CSS/SCSS/Less, PHP, Ruby, Perl, Bash/Zsh, PowerShell, Batch, Java, C#, SQL, XML,
    JSON/JSON5, YAML, TOML, Markdown, Diff, Makefile, CMake, Properties/INI, Ada, Assembly (x86/ARM),
    COBOL, CoffeeScript, D, Dart, Dockerfile, Erlang, Fortran, F#, GDScript, Haskell, Julia, Kotlin,
    LaTeX/TeX, Common Lisp/Scheme, MATLAB/Octave, Nim, Nix, OCaml, Pascal/Delphi, R, Scala, Tcl/Tk,
    Verilog HDL, VHDL, and Visual Basic.
  - Organized alphabetically with letter submenus (A–Z) across Menu Bar, Toolbar, and Status Bar.
  - Immediate Lexilla colorization (`SCI_COLOURISE`) on document load and switching.
- **Embedded Lua 5.5.1 Engine**: Built-in, sandboxed Lua 5.5.1 runtime with an interactive console and direct `editor.*` manipulation APIs for automation, macros, and plugin scripting.
- **Format Menu & Text Transformations**:
  - Convert Case relocated under the dedicated **Format** menu: `UPPERCASE` (`⇧⌘U`), `lowercase` (`⌃⌘L`), `Capitalize`, and `Invert Case`.
  - Block Indent (`Tab` / `increase.indent`) and Outdent (`⇧Tab` / `decrease.indent`).
  - White Space & EOL character display toggle (`paragraphsign`) and Indentation Guides toggle (`ruler`).
  - Smart word detection fallback when no text is explicitly selected.
- **SparkNotePad-Style Dedicated Find & Replace Dialog**:
  - Standalone modal dialog box featuring tabbed navigation (`Find` vs `Replace`).
  - Search options: Match Case, Whole Word Only, Regular Expression, and Wrap Around.
  - Direction controls (Up / Down) and comprehensive actions: Find Next (`Return`), Find Previous, Replace, Replace All, and Count occurrences across the entire buffer.
  - Continuous single replacement workflow: automatically substitutes matching selection and advances to next match.
  - Bidirectional wrap-around search in both normal and regular expression modes.
  - Smart Highlighting: automatically highlights occurrences of selected text or search queries using Scintilla native indicator 8 (`INDIC_ROUNDBOX`).
  - Collapsible in-window search bar (`⇧⌘F`) also available for lightweight inline searching.
- **Developer & Security Tools Hub**:
  - **Hash Tools**: Fast computation of MD5, SHA-1, SHA-256, SHA-384, SHA-512, and IEEE 802.3 CRC32 with real-time hash verification and checksum matching.
  - **Crypto Tools**: Military-grade AES-256-GCM encryption and decryption with PBKDF2-HMAC-SHA256 key derivation (100,000 iterations) and interactive password strength evaluation.
  - **MIME Tools**: Base64 encoding/decoding (full buffer and line-by-line), RFC 3986 URL percent encoding/decoding, and HTML entity encoding/decoding.
  - **Converter Tools**: ASCII to Hexadecimal (and reverse) and multi-base numeric converter (Binary, Octal, Decimal, Hexadecimal).
  - **Developer Tools**: JSON Prettify/Minify with custom indent spacing, XML formatting/minification, JWT token inspector (header, payload, claims, signature, expiration), UUID v4 generator, and Unix Epoch/ISO 8601 converter.
- **Bilingual Localization (i18n)**:
  - Full native support for **English** and **Bahasa Indonesia** across all menus, dialogs, toolbar controls, status badges, and toolkits.
- **Check for Updates Dialog**:
  - Live GitHub API integration for checking the latest releases and updates directly inside the application.
- **Rich Context Menu**:
  - Complete right-click contextual menu on the editor canvas with editing, find/replace submenus, case conversion, line navigation, and view toggles.
- **About, Credits & GPLv3 Licensing Panel**:
  - Tabbed panel featuring Application Details, Third-Party Component Credits (Scintilla 5.6.9, Lexilla 5.5.5, Lua 5.5.1, SparkNotePad & TextEdit), and GNU General Public License v3.0 statements.
- **Modern SwiftUI Chrome**:
  - Distinctive permanent dark toolbar (`#21252b`) with quick-action buttons.
  - Custom tab bar with document status badges (saved, unsaved/modified indicator dot, read-only) and color-coded tab tagging.
  - Multi-document tab management with automatic session state.
  - Responsive status bar with live cursor position (line, column), total line count, encoding, lexer language, and theme name.
  - Native Preferences sheet for Themes, Font family/size, and Lua scripting.
- **Universal Binary & Packaging**:
  - Ships as a fat universal binary supporting both **Apple Silicon (`arm64`)** and **Intel (`x86_64`)** architectures.
  - Packaging scripts for both `.app` bundle, `.zip` archive, and `.dmg` disk image.
- **7 Built-in Developer Themes**:
  - SparkNotePad Light
  - SparkNotePad Dark
  - One Dark Pro (Default Dark)
  - Dracula
  - Monokai
  - GitHub Light
  - Solarized Light

---

## Architecture

NotepadMac is organized into clean, modular Swift packages and targets:

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

## Building from Source

### Prerequisites

- macOS 11.0 (Big Sur) or newer
- Xcode 14+ or Apple Command Line Tools (`swift --version` 5.9+)
- Python 3 with Pillow (for icon generation)

### Quick Development Build (SPM)

```bash
# Clone the repository
git clone https://github.com/alsyundawy/NotepadMac.git
cd NotepadMac

# Build debug executable
swift build

# Run the debug binary
.build/debug/NotepadMac
```

### Production Universal App Bundle (`.zip` & `.dmg`)

To produce the official, signed **Universal `.app` bundle**, `.zip` archive, and `.dmg` disk image containing both `arm64` and `x86_64` binaries:

```bash
# 1. Build Universal App Bundle & ZIP
./scripts/build-app.sh

# 2. Package Universal DMG Disk Image
./scripts/build-dmg.sh
```

Distribution outputs are placed in the `build/` directory:

- `build/NotepadMac.app`
- `build/NotepadMac-1.0.0-macOS-Universal.zip`
- `build/NotepadMac-1.0.0-macOS-Universal.dmg`

---

## Keyboard Shortcuts

| Shortcut      | Action                       |
| :------------ | :--------------------------- |
| `⌘ N`         | New Document                 |
| `⌘ O`         | Open File                    |
| `⌘ S`         | Save File                    |
| `⇧ ⌘ S`       | Save As...                   |
| `⌥ ⌘ S`       | Save All Documents           |
| `⌘ W`         | Close Active Tab             |
| `⌥ ⌘ W`       | Close All Tabs               |
| `⌘ F`         | Toggle Find & Replace Bar    |
| `⌘ G`         | Find Next                    |
| `⇧ ⌘ G`       | Find Previous                |
| `⌘ E`         | Use Selection for Find       |
| `⇧ ⌘ U`       | Make UPPERCASE               |
| `⌃ ⌘ L`       | Make lowercase               |
| `⌥ ⌘ L`       | Open Lua Scripting Console   |
| `⌃ ⌘ T`       | Open Tools Hub               |
| `⌃ ⌘ H`       | Open Hash Tools              |
| `⌃ ⌘ M`       | Open MIME Tools (Base64/URL) |
| `⌃ ⌘ C`       | Open Base / Hex Converter    |
| `⌃ ⌘ E`       | Open AES-256 Encryption      |
| `⌃ ⌘ D`       | Open Developer Tools         |
| `⌘ L`         | Go To Line...                |
| `⌘ +` / `⌘ =` | Zoom In                      |
| `⌘ -`         | Zoom Out                     |
| `⌘ 0`         | Reset Zoom                   |
| `⌥ Z`         | Toggle Word Wrap             |
| `⌘ ,`         | Open Preferences             |

---

## License

This project is licensed under the **GNU General Public License v3.0 (GPLv3)**. See the [LICENSE](LICENSE) file for details.

Scintilla and Lexilla are copyright © Neil Hodgson. Lua is copyright © Lua.org, PUC-Rio.
