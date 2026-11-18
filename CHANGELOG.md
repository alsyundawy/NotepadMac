# Changelog

All notable changes to the **NotepadMac** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-11-17

### Added

- **Core Editing Engine**:
  - Integrated official **Scintilla 5.6.9** (Cocoa port) native C++17 editing engine.
  - Integrated official **Lexilla 5.5.5** syntax highlighters with 50+ supported programming languages.
  - Integrated official **Lua 5.5.1** embedded scripting and automation engine via native `CLua` C-bridge.
- **Languages & Lexers (50+ Languages)**:
  - Core languages: Plain Text, Lua, Python, Swift, C/C++, Objective-C/C++, Rust, Go, Zig, JavaScript, TypeScript, HTML, CSS, SCSS, Less, PHP, Ruby, Perl, Bash, Zsh, PowerShell, Batch, Java, C#, SQL, XML, JSON, JSON5, YAML, TOML, Markdown, Diff, Makefile, CMake, Properties/INI.
  - Extended Lexilla languages: Ada, Assembly (x86/ARM), COBOL, CoffeeScript, D, Dart, Dockerfile, Erlang, Fortran, F#, GDScript, Haskell, Julia, Kotlin, LaTeX/TeX, Common Lisp/Scheme, MATLAB/Octave, Nim, Nix, OCaml, Pascal/Delphi, R, Scala, Tcl/Tk, Verilog HDL, VHDL, Visual Basic.
  - Organized all 50+ languages alphabetically with dedicated letter submenus (A–Z) across the App Menu, Toolbar, and Status Bar.
  - Automatic Lexilla colorization (`SCI_COLOURISE`) on document load and tab switching.
- **SparkNotePad-Style Dedicated Find & Replace Dialog**:
  - Added `FindReplaceDialogView`: floating dialog window with tabbed Find and Replace modes.
  - Advanced search controls: Match case, Whole word only, Regular expression, and Wrap around.
  - Direction controls: Up and Down radio selectors.
  - Action buttons: Find Next (`Return`), Find Previous, Replace, Replace All, Count occurrences across the buffer, and Close (`Esc`).
  - Native count calculation engine for fast, non-moving occurrence detection with visual highlight marking.
  - Continuous single replacement workflow: replaces matching selection and immediately advances to next match.
  - Bidirectional wrap-around search in both normal and regular expression modes.
  - Smart Highlighting: automatically highlights occurrences of selected text or search queries using Scintilla native indicator 8 (`INDIC_ROUNDBOX`).
  - In-window collapsible search bar (`⇧⌘F`) retained for inline quick-search.
- **Themes & Styling (7 Developer Themes)**:
  - SparkNotePad Light, SparkNotePad Dark, One Dark Pro, Dracula, Monokai, GitHub Light, and Solarized Light.
  - Automatic BGR Scintilla color calculation and SwiftUI color-space synchronizers.
- **Text Transformations & Format Menu**:
  - Relocated Convert Case to the dedicated **Format** menu (`FormatMenuCommands`).
  - Added smart case conversion: `UPPERCASE` (`⇧⌘U`), `lowercase` (`⌃⌘L`), `Capitalize` (Title Case), and `Invert Case`.
  - Added block Indent (`Tab` / `increase.indent`) and Outdent (`⇧Tab` / `decrease.indent`) operations.
  - Added White Space / EOL character display toggle (`paragraphsign`) and Indentation Guides toggle (`ruler`).
  - Automatic word selection fallback when no active selection is present.
- **Toolbar & UI/UX Polish**:
  - Refined toolbar layout like Notepad++: Indent, Outdent, White Space & EOL, Indentation Guides, Zoom, Print, Undo, Redo, Cut, Copy, Paste, Find, and Replace with distinct separators and tooltips.
- **Editor Context Menu**:
  - Rich right-click contextual menu featuring Undo, Redo, Cut, Copy, Paste, Duplicate Line, Delete Line, Select All, Find/Replace submenus, Convert Case submenu, Go to Line, Insert Date/Time, and View toggles.
- **Modern About, Credits & GPLv3 Licensing Panel**:
  - Tabbed interface featuring Application Overview, Third-Party Credits & Sources, and GNU General Public License v3.0 statement.
  - Full third-party notices for Scintilla Cocoa (HPND / Neil Hodgson), Lexilla (HPND / Neil Hodgson), and Lua (MIT / PUC-Rio).
- **Licensing**:
  - Re-licensed NotepadMac under **GNU General Public License v3.0 or later** (`GPL-3.0-or-later`).
- **Developer & Power Tools Suite (`Sources/NotepadMac/Tools/`)**:
  - `HashTools`: Fast MD5, SHA-1, SHA-256, SHA-384, SHA-512, and IEEE 802.3 CRC32 hash calculation with checksum comparator.
  - `CryptoTools`: AES-256-GCM authenticated encryption/decryption with PBKDF2-HMAC-SHA256 key derivation (100,000 rounds) and password strength scoring.
  - `MimeTools`: Base64 encoder/decoder (full and line-by-line), RFC 3986 URL encoder/decoder, and HTML entity encoder/decoder.
  - `ConverterTools`: ASCII to Hexadecimal (and reverse) and multi-base converter (Binary, Octal, Decimal, Hexadecimal).
  - `DeveloperTools`: JSON Prettify/Minify with custom indent spacing, XML formatter/minifier, JWT token inspector, UUID v4 generator, and Unix Epoch / ISO 8601 converter.
- **Bilingual Localization (`LocalizationManager`)**:
  - Complete native localization in English and Bahasa Indonesia (`id`) across all menus, toolbars, dialogs, status badges, and toolkits.
- **Check for Updates Dialog (`CheckUpdateDialogView`)**:
  - Native update checker with GitHub Releases API integration and release notes display.
- **Tools Hub Dialog (`ToolsDialogView`)**:
  - Unified modal interface organizing all 5 tool categories with interactive inputs, live calculations, copy-to-clipboard, and insertion directly into the active editor buffer.
- **Performance & Security Hardening**:
  - Zero-allocation `lineCount` computation utilizing native UTF-8 byte traversal instead of line-array allocation.
  - Hardened cryptographic buffer pointer access in `CryptoTools` with graceful error propagation, completely removing force unwraps.
- **Tooling & Compilation Database**:
  - Generated root `compile_commands.json` (211 translation units) and `.vscode/c_cpp_properties.json` for zero-error SonarLint, clangd, and C/C++ language server integration.
- **Packaging & CI/CD**:
  - Universal Fat Binary (`arm64` Apple Silicon + `x86_64` Intel) build scripts: `build-app.sh` and `build-dmg.sh`.
  - GitHub Actions automated Universal Build workflow (`.github/workflows/build-universal.yml`) with automated DMG & ZIP release publishing.
  - GitHub Actions MegaLinter integration (`.github/workflows/mega-linter.yml` & `.mega-linter.yml`).
  - CodeQL advanced security analysis workflow.
