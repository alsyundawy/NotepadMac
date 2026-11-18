# Changelog

All notable changes to **NotepadMac** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-11-19

### 🌟 Release: Production Native macOS Text Editor (Scintilla Cocoa 5.6.9, Lexilla 5.5.5, Embedded Lua 5.5.1, Developer & Security Tools Hub, Modern Find/Replace/Mark Hub, Data Loss Prevention Guard, Focus Ring Elimination & Universal Binary)

NotepadMac v1.0.0 marks the initial major production release of the fast, lightweight, and modern native macOS desktop text editor powered by Scintilla Cocoa 5.6.9, Lexilla 5.5.5, SwiftUI, AppKit, and an embedded sandboxed Lua 5.5.1 scripting engine.

#### 🆕 Added

- **Core Editing Engine (Scintilla Cocoa 5.6.9 & Lexilla 5.5.5)**:
  - Integrated official **Scintilla 5.6.9** (Cocoa port) native C++17 editing engine via `ScintillaCocoa` with hardware-accelerated text layout, caret rendering, multi-selection, and undo/redo stacks.
  - Integrated official **Lexilla 5.5.5** syntax highlighters supporting 50+ programming languages with hierarchical code folding.
  - Automatic Lexilla syntax colorization (`SCI_COLOURISE`) on document load, tab switching, and content mutations.
  - Zero-allocation UTF-8 byte traversal in `EditorDocument.lineCount`, replacing costly line-array allocations.
- **50+ Programming Languages & Extended Lexers**:
  - Core languages: Plain Text, Lua, Python, Swift, C/C++, Objective-C/C++, Rust, Go, Zig, JavaScript, TypeScript, HTML, CSS, SCSS, Less, PHP, Ruby, Perl, Bash, Zsh, PowerShell, Batch, Java, C#, SQL, XML, JSON, JSON5, YAML, TOML, Markdown, Diff, Makefile, CMake, Properties/INI.
  - Extended Lexilla languages: Ada, Assembly (x86/ARM), COBOL, CoffeeScript, D, Dart, Dockerfile, Erlang, Fortran, F#, GDScript, Haskell, Julia, Kotlin, LaTeX/TeX, Common Lisp/Scheme, MATLAB/Octave, Nim, Nix, OCaml, Pascal/Delphi, R, Scala, Tcl/Tk, Verilog HDL, VHDL, Visual Basic.
  - Organized all 50+ languages alphabetically with dedicated letter submenus (A–Z) across the App Menu, Toolbar, and Status Bar.
- **Embedded Sandboxed Lua 5.5.1 Automation Engine**:
  - Built-in sandboxed Lua 5.5.1 runtime initialized via `CLuaBridge` C-bridge.
  - Interactive **Lua Console** sheet (`⌘K`) with script execution log, clear console button, and standard error handling.
  - Exposed direct `editor.*` APIs for automation, macros, and plugin scripting:
    - `editor.getText()`: Returns buffer text
    - `editor.setText(string)`: Replaces buffer content
    - `editor.getSelection()`: Returns selected substring
    - `editor.replaceSelection(string)`: Overwrites current selection
    - `editor.getLineCount()`: Returns total lines
    - `editor.getCurrentLine()`: Returns cursor line index
    - `editor.insertText(position, string)`: Inserts string at offset
    - `editor.clear()`: Resets editor buffer
    - `editor.zoomIn()` / `editor.zoomOut()`: Adjusts zoom level
- **Modernized Find, Replace & Mark Hub (`FindReplaceDialogView`)**:
  - Dedicated standalone modal dialog window aligned with Tools Hub design tokens and macOS Human Interface Guidelines.
  - Native segmented tab navigation across **Find**, **Replace**, and **Mark** modes.
  - Comprehensive search controls: Match Case (`Aa`), Whole Word Only (`\b`), Regular Expression (`.*`), and Wrap Around (`↩`).
  - Bidirectional search: Direction Up (`arrow.up`) and Down (`arrow.down`) radio selectors.
  - Action buttons: Find Next (`Return`), Find Previous, Replace, Replace All, and Count occurrences across the entire buffer.
  - Full Notepad++ **Mark** subsystem: Mark All with Indicator 8 (`INDIC_ROUNDBOX`) highlighting, line bookmarking in margin 1 (`🔖`), Clear All Marks, and Copy Marked Text.
  - Continuous single replacement workflow: replaces current selection and automatically advances to next match.
  - In-window collapsible search bar (`⇧⌘F`) retained for inline quick-search with full localization and quick-expand button.
- **Developer & Security Tools Hub (`ToolsDialogView` & `Sources/NotepadMac/Tools/`)**:
  - **Developer Tools**:
    - **HTML, JSON, CSS & JavaScript Minify & Unminify (Prettify)**: Syntax-aware beautification and minification with configurable indent spacing.
    - **HTML Encrypt & Decrypt Engine**: Inspired by `html-code-generator.com`, featuring client-side JS `unescape`, Base64 dynamic evaluation, and password-protected standalone AES-GCM Web Crypto HTML containers.
    - XML document validator and minifier.
    - JWT token inspector with header, claims, payload, and exp/iat timestamp parsing.
    - UUID v4 generator.
    - Unix Epoch timestamp / ISO 8601 converter.
  - **Hash Tools**:
    - High-performance cryptographic hash computation (MD5, SHA-1, SHA-256, SHA-384, SHA-512) via Apple `CryptoKit` and IEEE 802.3 CRC32 with precomputed lookup table.
    - Real-time text hash calculation with instant copy-to-clipboard.
    - **File Checksum Generator & Verifier**: Memory-mapped (`.mappedIfSafe`) streaming file hash computation supporting direct file attachment (`NSOpenPanel`), expected checksum validation (`✓ MATCH` / `✗ MISMATCH`), and two-file byte-for-byte comparison.
  - **Crypto Tools**:
    - Military-grade AES-256-GCM authenticated encryption and decryption.
    - PBKDF2-HMAC-SHA256 key derivation (100,000 iterations, 16-byte cryptographically secure salt via `SecRandomCopyBytes`, 12-byte nonce, 16-byte authentication tag).
    - Self-describing `NPMENC01:` container format.
    - Interactive password strength evaluation.
  - **MIME Tools**:
    - RFC 4648 Base64 encoding and decoding (full buffer and line-by-line).
    - RFC 3986 URL percent-encoding and decoding.
    - HTML entity encoding and decoding.
  - **Converter Tools**:
    - ASCII to Hexadecimal string translation (and reverse).
    - Multi-base numeric converter (Binary, Octal, Decimal, Hexadecimal).
- **Data Loss Prevention Guard (Unsaved Changes Protection)**:
  - Native confirmation sheet (`NSAlert`) triggered before closing modified tabs, closing other tabs, closing tabs to the right, closing the window, and quitting the application (`⌘Q`).
  - Standard options: **Save** (`Return`), **Don't Save** (`⌘D`), and **Cancel** (`Esc`).
  - Automatically switches tab focus to the modified document so changes can be visually inspected before making a decision.
  - Intercepts `NSWindowDelegate.windowShouldClose` and `NSApplicationDelegate.applicationShouldTerminate` (`.terminateCancel` cleanly preserves buffers).
- **7 Handcrafted Developer Color Themes**:
  - SparkNotePad Light, SparkNotePad Dark, One Dark Pro (Default Dark), Dracula, Monokai, GitHub Light, and Solarized Light.
  - Automatic BGR Scintilla color calculation and SwiftUI color-space synchronizers.
- **Native Format Menu & Text Transformations**:
  - Dedicated **Format** menu (`FormatMenuCommands`) in menu bar.
  - Case conversions: `UPPERCASE` (`⇧⌘U`), `lowercase` (`⌃⌘L`), `Capitalize` (Title Case), and `Invert Case`.
  - Block Indent (`Tab` / `increase.indent`) and Outdent (`⇧Tab` / `decrease.indent`).
  - White Space & EOL character display toggle (`paragraphsign`) and Indentation Guides toggle (`ruler`).
  - Smart word detection fallback when no text is explicitly selected.
- **Bilingual Localization (i18n)**:
  - Full native support for **English** and **Bahasa Indonesia** (`id`) across all menus, toolbars, status bars, dialogs, status badges, and toolkits via `LocalizationManager`.
  - Instant reactive language switching without application restart.
- **Check for Updates Dialog (`CheckUpdateDialogView`)**:
  - Native update checker with GitHub Releases REST API integration and release notes display.

#### 🛡️ Security Hardening (2025–2026 CVE Audit)

- **CVE-2025-15556 Immunity**: Notepad++ updaters prior to v8.8.9 lacked cryptographic package verification (WinGUp updater flaw). NotepadMac is immune: it does not use WinGUp, and update queries are read-only HTTPS requests against GitHub Releases API without executing unverified binaries.
- **CVE-2025-49144, CVE-2026-73250, CVE-2026-25926 Immunity**: Insecure search path in Windows installers allowing binary planting (LPE). NotepadMac is immune: macOS Mach-O binaries load from sandboxed app bundles with standard drag-and-drop `.dmg` distribution.
- **CVE-2026-52884 Immunity**: Path traversal flaw in Notepad++ Run Dialog `isInTrustedDirectory()` allowing command execution outside trusted folders via `..\..\`. NotepadMac is immune: resolves all paths through Foundation `URL` with sandbox path canonicalization and does not expose unverified `ShellExecute` commands.
- **Memory Safety & Pointer Hardening**: Hardened cryptographic buffer pointer access in `CryptoTools` with graceful error propagation, completely eliminating force unwraps (`!`).
- **Scintilla 5.6.9 & Lexilla 5.5.5 Invariants**: C++17 memory-safe buffer management with bounded style runs and zero fixed-size stack buffers.

#### 🔧 Changed & Improved

- **Modernized Tab Bar & Toolbar Ergonomics**:
  - Distinctive permanent dark toolbar (`#21252b`) locked across all themes to preserve icon contrast.
  - Custom tab bar with document status badges (saved, unsaved/modified indicator dot, read-only) and color-coded tab tagging.
  - Responsive status bar with live cursor position (line, column), total line count, encoding, lexer language, and theme name.
  - Comprehensive right-click context menu on editor canvas with editing, find/replace submenus, case conversion, line navigation, and view toggles.

#### 🐞 Fixed

- **Focus Ring & Blue Square Background Artifact Elimination (`ModalCloseButton`)**:
  - Completely eliminated the macOS AppKit blue focus ring / rectangular background artifact around dialog close icons by introducing `ModalCloseButton`.
  - Decoupled the visible glyph (`Image` with `.contentShape(Circle())`, `.onHover`, and `.onTapGesture`) from an invisible zero-size key equivalent receiver (`Button` with `.frame(width: 0, height: 0)`, `.opacity(0)`, `.focusable(false)`, and `.keyboardShortcut(.cancelAction)`).
  - Applied across `ToolsDialogView`, `FindReplaceDialogView`, `CheckUpdateDialogView`, and `FindReplaceBar`.
  - Replaced text-field clear buttons (`xmark.circle`) in `FindReplaceBar` and `FindReplaceDialogView` with direct tap-gesture glyphs.
  - Refactored tab close buttons in `NotepadTabBar` with native circular hover and tap gestures, ensuring clean rendering with zero focus outline artifacts during tab navigation.
- **Dialog Box Icon Polish**:
  - Removed accidental filled circular and rectangular backgrounds behind icons across Find/Replace, Tools Hub, Update Checker, and About dialogs.
- **DMG Packaging Race Condition**:
  - Fixed filesystem synchronization race condition on `hdiutil verify` in `scripts/build-dmg.sh` by introducing `sync` and a brief delay before verification.

#### 📦 Packaging & CI/CD

- **Universal Binary Build Pipeline (`scripts/build-app.sh`)**:
  - Dual-architecture compilation for **Apple Silicon (`arm64`)** and **Intel (`x86_64`)** via Swift Package Manager (`swift build -c release`).
  - Fat binary creation using `lipo -create` and ad-hoc code-signing (`codesign --force --deep --sign -`).
  - Produces universal application bundle `build/NotepadMac.app` and distribution zip `build/NotepadMac-1.0.0-macOS-Universal.zip`.
- **Universal DMG Packaging (`scripts/build-dmg.sh`)**:
  - Packages `NotepadMac.app` with an `/Applications` symlink into a compressed `UDZO` disk image (`build/NotepadMac-1.0.0-macOS-Universal.dmg`) with verified CRC32 checksum.
- **Automated CI/CD Workflows**:
  - `.github/workflows/build-universal.yml`: Automated CI that builds, tests, packages DMG and ZIP, and publishes GitHub releases on version tags.
  - `.github/workflows/mega-linter.yml`: Automated code quality gate scanning Swift, Shell, YAML, Markdown, and Python.

#### 👥 Credits & Acknowledgments

- **Harry Dertin Sutisna Alsyundawy (@alsyundawy)** — Lead Developer, Architect & Maintainer, ALSYUNDAWY IT SOLUTION.
- **Scintilla & Lexilla** — Neil Hodgson & Scintilla Contributors (HPND License).
- **Lua Programming Language** — Roberto Ierusalimschy, Waldemar Celes, Luiz Henrique de Figueiredo / PUC-Rio (MIT License).
- **SparkNotePad** — Harry Dertin Sutisna Alsyundawy & ALSYUNDAWY IT SOLUTION (GPLv3).
- **Notepad++** — Don Ho & Notepad++ Contributors (GPLv3).
- **Apple Inc.** — AppKit, SwiftUI, and macOS Platform SDKs.
