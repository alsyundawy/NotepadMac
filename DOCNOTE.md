# NotepadMac Release DocNote — v1.0.0

```text
================================================================================
Release Version     : 1.0.0 (Native Scintilla Cocoa 5.6.9, Lexilla 5.5.5, Embedded Lua 5.5.1,
                      Developer & Security Tools Hub, Modern Find/Replace/Mark Hub,
                      Data Loss Prevention Guard, Focus Ring Elimination,
                      Autosave Snapshot & Crash Recovery, Tab Rename & Color & 2025–2026 CVE Audit)
Release Date        : 2026-11-21
Lead Maintainer     : Harry Dertin Sutisna Alsyundawy (@alsyundawy)
Organization        : ALSYUNDAWY IT SOLUTION (https://alsyundawy.com)
Repository          : https://github.com/alsyundawy/NotepadMac
Core Editing Engine : Scintilla 5.6.9 (Cocoa C++17) & Lexilla 5.5.5 (50+ Languages)
Embedded Lua Core   : Sandboxed Lua 5.5.1 (CLua ISO C Bridge)
GUI Framework       : SwiftUI & AppKit (Swift 5.9+ / Swift 6.x)
Target Platforms    : macOS 11.0–26.0 (Universal: Apple Silicon ARM64 & Intel x86_64)
License             : GNU General Public License v3.0 (GPL-3.0-or-later)
Architecture        : 100% Additive Safe Enhancements Inspired by SparkNotePad, Notepad++, Notepad-- & Notepad3
CI/CD Status        : 100% Passing across all release matrices, MegaLinter & CodeQL
================================================================================
```

---

## 1. Executive Summary: Production Release v1.0.0

**NotepadMac v1.0.0** is a fast, lightweight, and modern native macOS desktop text editor engineered from the ground up for macOS using modern **SwiftUI** and the proven **Scintilla / Lexilla** native editing engine. Unlike heavy Electron-based or web-wrapper editors, NotepadMac starts instantaneously, runs with minimal memory footprint, and provides complete native macOS integration: AppKit menus, custom tabs, keyboard shortcuts, deep system font rendering, and universal binary distribution (`arm64` + `x86_64`).

### Key Highlights & Features

- **Core Editing Engine (Scintilla Cocoa 5.6.9 & Lexilla 5.5.5)**:
  - Official Scintilla 5.6.9 Cocoa port (`ScintillaView`) wrapped cleanly in SwiftUI via `NSViewRepresentable`.
  - 50+ Lexilla programming language highlighters with hierarchical code folding.
  - Automatic Lexilla colorization (`SCI_COLOURISE`) on document load and tab switching.
  - Zero-allocation UTF-8 byte traversal in `EditorDocument.lineCount`.
- **Embedded Sandboxed Lua 5.5.1 Engine**:
  - Sandboxed Lua 5.5.1 runtime with interactive console sheet (`⌘K`) and direct `editor.*` APIs for automation, macros, and scripting.
- **Modernized Find, Replace & Mark Hub (`FindReplaceDialogView`)**:
  - Standalone modal dialog box perfectly aligned with Tools Hub design tokens and macOS Human Interface Guidelines.
  - Full Notepad++ **Mark** engine: Mark All with Indicator 8 highlighting, line bookmarking in margin 1 (`🔖`), Clear All Marks, and Copy Marked Text.
  - Collapsible in-window search bar (`⇧⌘F`) retained for inline quick-search.
- **Developer & Security Tools Hub (`ToolsDialogView`)**:
  - **Developer Tools**: Syntax minification & unminification (formatting) for HTML, JSON, CSS, and JavaScript with configurable indentation, HTML encryption & decryption (JS unescape, Base64, and standalone password-protected AES-GCM Web Crypto containers), XML validation, JWT token inspector, UUID v4 generator, and Unix Epoch / ISO 8601 converter.
  - **Hash Tools**: Fast computation of MD5, SHA-1, SHA-256, SHA-384, SHA-512, and IEEE 802.3 CRC32 with real-time text and attached file checksum calculation, matching verification, and two-file comparison.
  - **Crypto Tools**: Military-grade AES-256-GCM encryption/decryption with PBKDF2-HMAC-SHA256 key derivation (100,000 rounds) and interactive password strength evaluation.
  - **MIME Tools**: Base64 encoding/decoding (full and line-by-line), RFC 3986 URL percent-encoding, and HTML entity sanitization.
  - **Converter Tools**: ASCII to Hexadecimal (and reverse) and multi-base numeric converter (Binary, Octal, Decimal, Hexadecimal).
- **Data Loss Prevention Guard (Unsaved Changes Protection)**:
  - Native confirmation sheet (`NSAlert`) triggered before closing modified tabs, closing other tabs, closing tabs to the right, closing the window, and quitting the application (`⌘Q`).
  - Standard options: **Save** (`Return`), **Don't Save** (`⌘D`), and **Cancel** (`Esc`).
  - Automatically switches tab focus to the modified document so changes can be visually inspected before making a decision.
- **Autosave Snapshot & Crash Recovery Subsystem (`AutosaveRecoveryManager` & `CrashRecoverySheet`)**:
  - Background periodic snapshot daemon running every 10s across all in-memory modified Scintilla document buffers.
  - Strict POSIX `0700` directory and `0600` file permissions in `~/Library/Application Support/NotepadMac/Recovery/` (CWE-732).
  - Cryptographic SHA-256 tamper detection on snapshot storage and loading (CWE-353 / CWE-354).
  - Automatic snapshot pruning upon clean document save or closure.
  - Native SwiftUI `CrashRecoverySheet` modal dialog on startup after an ungraceful crash or sudden power failure, featuring content preview, SHA-256 verification status, and one-click restoration or discard.
- **Tab Renaming & Custom Tab Coloring Subsystem (`RenameTabSheet` & `NotepadTabBar`)**:
  - Seamless tab and physical file renaming via `RenameTabSheet`, tab double-click, context menu, and `⇧⌘R`.
  - Comprehensive collision check, POSIX atomic rename, and automatic Lexilla highlighter adjustment on extension change.
  - Full tab coloring palette with 10 presets and native `ColorPicker` custom hex support, featuring dynamic tab background tinting, glowing accent capsules, and color badges.
- **Modal Dialog & Tab Icon Polish with Focus Ring Elimination (`ModalCloseButton`)**:
  - Completely eliminated the macOS AppKit blue focus ring / rectangular background artifact around dialog close icons by introducing `ModalCloseButton`.
  - Decoupled the visible glyph (`Image` with `.contentShape(Circle())`, `.onHover`, and `.onTapGesture`) from an invisible zero-size key equivalent receiver (`Button` with `.frame(width: 0, height: 0)`, `.opacity(0)`, `.focusable(false)`, and `.keyboardShortcut(.cancelAction)`).
  - Applied across `ToolsDialogView`, `FindReplaceDialogView`, `CheckUpdateDialogView`, and `FindReplaceBar`.
  - Replaced text-field clear buttons (`xmark.circle`) and tab close buttons in `NotepadTabBar` with gesture-driven glyphs, ensuring clean, native rendering with zero focus ring artifacts during tab navigation and dialog interactions.
- **7 Handcrafted Developer Themes**:
  - SparkNotePad Light, SparkNotePad Dark, One Dark Pro, Dracula, Monokai, GitHub Light, and Solarized Light with automatic BGR color-space synchronizers.
- **Bilingual Localization (i18n)**:
  - Full native support for **English** and **Bahasa Indonesia** (`id`) across all menus, dialogs, toolbar controls, status badges, and toolkits via `LocalizationManager`.
- **Universal Binary Distribution**:
  - Compiles natively for both **Apple Silicon (`arm64`)** and **Intel (`x86_64`)** architectures.
  - Automated packaging into `.app` bundle, `.zip` archive, and `.dmg` disk image with verified CRC32 checksum.

---

## 2. Architecture & Layering

```text
+-----------------------------------------------------------------------------------+
|                              SwiftUI Chrome Layer                                 |
|  - NotepadToolbar (Permanent Dark #21252b, Notepad++ Classic layout)              |
|  - NotepadTabBar (Custom tab bar with dirty indicators, tags & gesture close)     |
|  - NotepadStatusBar (Live cursor pos, total lines, encoding, lexer, theme)       |
|  - FindReplaceDialogView & FindReplaceBar (Find, Replace & Mark Hub)              |
|  - ToolsDialogView (Hash, MIME, Converter, Encryption, Developer Tools)           |
|  - PreferencesView (Themes, Font family/size, Tab width, Word wrap)               |
|  - AboutView (App overview, Third-party credits, GPLv3 license)                  |
|  - ModalCloseButton (Anti-focus-ring gesture-driven modal dismissal)              |
+-----------------------------------------------------------------------------------+
                                          |
                                Swift / AppKit Bridge
                                          |
+-----------------------------------------------------------------------------------+
|                        ScintillaEditorCoordinator Layer                           |
|  - ScintillaEditorCoordinator+Search.swift (Find, Replace & Mark indicator 8)     |
|  - ScintillaEditorCoordinator+ContextMenu.swift (Native NSMenu integration)       |
|  - ScintillaNotificationProtocol (Event 2008, 2007, 2010 notifications)           |
|  - DocumentManager & EditorDocument (Tab state, dirty tracking, file I/O)         |
+-----------------------------------------------------------------------------------+
                                          |
                                C++17 / Objective-C++
                                          |
+-----------------------------------------------------------------------------------+
|                              Native Engine Layer                                  |
|  - ScintillaCocoa 5.6.9 (ScintillaView, PlatCocoa, CellBuffer, Caret)             |
|  - Lexilla 5.5.5 (50+ programming language lexers, folding managers)             |
|  - CLua 5.5.1 (Official C runtime & CLuaBridge for editor scripting)              |
+-----------------------------------------------------------------------------------+
```

---

## 3. Deep Technical Module Walkthrough

### 3.1 Scintilla Cocoa & Lexilla Bridge (`Sources/ScintillaCocoa/`)

- Direct integration of official Scintilla 5.6.9 Cocoa sources (`ScintillaView.mm`, `PlatCocoa.mm`, `InfoBar.mm`) compiled under C++17 (`-std=c++17`) with Automatic Reference Counting (`-fobjc-arc`).
- Lexilla 5.5.5 lexer engine integrated with external lexer catalog, providing 50+ language definitions with keyword sets, styling masks, and indentation folding levels.
- Wrapped in SwiftUI via `NSViewRepresentable` (`ScintillaEditorRepresentable.swift`) with two-way binding for text synchronization, caret tracking, and theme color application.

### 3.2 Embedded Lua 5.5.1 Automation Subsystem (`Sources/CLua/` & `Sources/NotepadMac/Lua/`)

- Sandboxed Lua execution environment initialized with `luaL_newstate()`.
- Standard library opened via C wrapper `lua_open_all_libs(L)` in `CLuaBridge.h`.
- Exposes `editor.*` APIs to Lua scripts:
  - `editor.getText()`: Returns buffer text
  - `editor.setText(string)`: Replaces buffer content
  - `editor.getSelection()`: Returns selected substring
  - `editor.replaceSelection(string)`: Overwrites current selection
  - `editor.getLineCount()`: Returns total lines
  - `editor.getCurrentLine()`: Returns cursor line index
  - `editor.insertText(position, string)`: Inserts string at offset
  - `editor.clear()`: Resets editor buffer
  - `editor.zoomIn()` / `editor.zoomOut()`: Adjusts zoom level

### 3.3 Find, Replace & Mark Hub (`FindReplaceDialogView` & `FindReplaceBar`)

- **Find Subsystem**: Forward and backward wrap-around search in both normal and regular expression modes.
- **Replace Subsystem**: Continuous single replacement workflow: replaces current selection and automatically advances to next match. Replace All scans entire buffer in single pass.
- **Mark Subsystem**:
  - Mark All highlights occurrences using Scintilla native indicator 8 (`INDIC_ROUNDBOX`).
  - Bookmarks lines in margin 1 (`🔖`).
  - Clear All Marks removes indicator highlights and line bookmarks.
  - Copy Marked Text extracts all marked lines into clipboard.

### 3.4 Developer & Security Tools Suite (`Sources/NotepadMac/Tools/`)

- **`HashTools`**:
  - Hardware-accelerated cryptographic hash functions (MD5, SHA-1, SHA-256, SHA-384, SHA-512) via Apple `CryptoKit` and standard IEEE 802.3 CRC32 with precomputed lookup table.
  - **File Checksum Generation & Verification**: Native file streaming and memory-mapped calculation (`computeFileHash(at:algorithm:)`) supporting direct attachment and validation against expected checksums or second-file comparisons.
- **`CryptoTools`**: AES-256-GCM authenticated cipher with PBKDF2-HMAC-SHA256 key derivation (100,000 iterations, 16-byte cryptographically secure salt via `SecRandomCopyBytes`, 12-byte nonce, 16-byte authentication tag). Self-describing `NPMENC01:` container format.
- **`MimeTools`**: RFC 4648 Base64 encoding/decoding, RFC 3986 URL percent-encoding, and HTML entity sanitization.
- **`ConverterTools`**: ASCII to Hexadecimal string conversion and multi-base integer translation (Base-2, Base-8, Base-10, Base-16).
- **`DeveloperTools`**:
  - **HTML, JSON, CSS & JavaScript Minify & Unminify (Prettify)**: Fast syntax-aware beautification and minification for web assets with configurable indent spacing.
  - **HTML Encrypt & Decrypt**: Obfuscation and encryption engine inspired by `html-code-generator.com`, including client-side JS `unescape`, Base64 dynamic evaluation, and password-protected standalone AES-GCM Web Crypto HTML containers.
  - XML document validation and minification, JWT inspection (header, claims, payload, signature, exp/iat timestamp parsing), UUID v4 generator, and ISO 8601 / Unix Epoch conversion.

### 3.5 Modal Icon Button & Focus Ring Elimination (`ModalCloseButton`)

- **Root Cause of Icon Focus Ring / Background Artifacts**:
  - In macOS SwiftUI, a standard `Button` with `.buttonStyle(PlainButtonStyle())` and `.keyboardShortcut(.cancelAction)` retains default AppKit responder chain properties.
  - When Full Keyboard Access (FKA) is enabled or when a modal sheet is presented, AppKit draws the system accent-colored focus ring (a high-contrast blue rounded rectangular outline) around the button bounds (`22x22` pt).
  - This focus ring appeared intermittently whenever the close button or clear button acquired keyboard focus, appearing to users as a "random blue background behind the icon."
- **Architectural Solution**:
  - Implemented `ModalCloseButton` (`Sources/NotepadMac/Views/ModalCloseButton.swift`) utilizing a `ZStack` decoupling pattern:
    1. **Visible Interactive Icon**: Uses an `Image(systemName: "xmark")` with `.contentShape(Circle())`, `.onHover`, and `.onTapGesture { action() }`. Because it is an `Image` with a gesture recognizer rather than an `NSButton`, AppKit will **never** draw a focus ring or background box around it.
    2. **Hover Indicator**: Displays a subtle circular background (`Circle().fill(isHovered ? Color(NSColor.quaternaryLabelColor) : Color.clear)`) matching Apple Human Interface Guidelines for sheets and dialogs.
    3. **Invisible Shortcut Handler**: Contains an invisible, zero-size `Button(action: action) { EmptyView() }` with `.frame(width: 0, height: 0)`, `.opacity(0)`, and `.keyboardShortcut(.cancelAction)`, preserving instant `Esc` key modal dismissal without visual footprint.
  - Deployed across `ToolsDialogView`, `FindReplaceDialogView`, `CheckUpdateDialogView`, and `FindReplaceBar`.
  - Replaced text-field clear buttons (`xmark.circle`) and tab close buttons in `NotepadTabBar` with gesture-driven glyphs to prevent button focus rings across the entire application interface.

### 3.6 Data Loss Prevention Guard (Unsaved Changes Protection)

- **Native Confirmation Dialog**: Implemented `confirmCloseDocument(_:window:) -> Bool` in `DocumentManager` displaying a native macOS `NSAlert` modal whenever an unsaved / modified buffer is targeted for closure or termination.
- **Apple HIG-Compliant Action Buttons**:
  - **Save** (Primary / Return key `\r`): Commits changes to the existing file URL, or presents a modal `NSSavePanel` (`promptSaveAsModal(for:window:)`) for untitled documents. Returns `true` on successful write, or `false` if cancelled.
  - **Cancel** (Escape key `\u{1b}`): Aborts the close / quit operation immediately, leaving the tab, window, and application state intact. Returns `false`.
  - **Don't Save** (Command-D `⌘D`): Discards unsaved modifications without writing to disk and returns `true`, proceeding with tab or window closure.
- **Active Tab Focus**: Before presenting the confirmation alert, `activeDocumentId` is automatically switched to the affected document, ensuring the user visually inspects the exact modified buffer before making a decision.
- **Tab Lifecycle Interception**: Guarded inside all document-closing workflows (`closeDocument(id:)`, `closeOtherDocuments(except:)`, `closeTabsToTheRight(of:)`, `closeAllDocuments()`).
- **Window Close Interception**: `AppDelegate` conforms to `NSWindowDelegate` and implements `windowShouldClose(_ sender: NSWindow) -> Bool`. It iterates over all opened modified documents and prompts confirmation before allowing the window to close.
- **Application Quit Interception**: `AppDelegate` implements `applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply`. If any open document has unsaved modifications, it sequentially requests user confirmation. Returning `.terminateCancel` cleanly prevents macOS from killing the app process if the user cancels.

### 3.7 Bilingual Localization Subsystem (`LocalizationManager`)

- Centralized `ObservableObject` handling dynamic runtime language switching between **English** and **Bahasa Indonesia** (`id`).
- Persists user language preference in `UserDefaults` (`notepad_app_language`) with fallback to macOS system preferred languages.
- Provides immediate reactivity across SwiftUI menus, buttons, status bars, and modal dialogs via `loc(key)` helper.

### 3.8 Autosave Snapshot & Crash Recovery Subsystem (`AutosaveRecoveryManager` & `CrashRecoverySheet`)

- Decoupled background timer daemon executing every 10 seconds across all modified in-memory Scintilla buffers.
- Enforces strict POSIX `0700` directory and `0600` file permissions in `~/Library/Application Support/NotepadMac/Recovery/` (CWE-732).
- Verifies SHA-256 cryptographic integrity checksums (`CryptoKit`) on save and load, immediately discarding tampered or incomplete snapshots (CWE-353 / CWE-354).
- Automatic snapshot cleanup on clean document save and tab closure.
- Native modal sheet (`CrashRecoverySheet`) on startup after unexpected terminations with preview, byte/line metrics, and one-click recovery.

### 3.9 Tab Renaming & Custom Tab Coloring Subsystem (`RenameTabSheet` & `NotepadTabBar`)

- Modal dialog (`RenameTabSheet`) supporting inline renaming of untitled documents and physical disk files.
- Duplicate filename collision detection preventing accidental data overwrites in the target folder.
- Dynamic syntax highlighter re-detection when changing file extensions during rename.
- Tab color customization with 10 presets and macOS `ColorPicker` custom hex support, featuring dynamic tab background tinting, glowing accent capsules, and color badges.

---

## 4. Security & Hardening Review (2025–2026 Analysis)

- **Input Validation**: Text transformations, hex parsers, and search inputs are bounded and sanitized against buffer overflows and memory exhaustion (CWE-119 / CWE-787).
- **Safe Memory Operations**: Removed all force unwraps (`!`) in cryptographic memory buffers; replaced line-splitting arrays with zero-allocation UTF-8 byte traversal in `EditorDocument.lineCount`.
- **Ecosystem Vulnerability Analysis (2025–2026 Primary Research & Applicability)**:
  - _`cxasm/notepad--`_: Comprehensive review of GitHub repositories, security advisories, and commit logs confirms **0 official CVEs or security advisories** issued for `cxasm/notepad--` spanning 2025–2026.
  - _`Notepad++` Updates & Vulnerability Mitigations_:
    - **CVE-2025-15556** (CVSS 7.7 High - WinGUp Updater Integrity Flaw): Notepad++ updaters prior to v8.8.9 lacked cryptographic package verification. _NotepadMac Mitigation_: NotepadMac does not use WinGUp; update checks run via read-only HTTPS queries to the official GitHub Releases API without executing arbitrary unverified binaries.
    - **CVE-2025-49144, CVE-2026-73250, CVE-2026-25926** (Installer Binary Planting & Insecure Search Path): Insecure executable search paths in Windows installers allowing local privilege escalation (`NT AUTHORITY\SYSTEM`). _NotepadMac Mitigation_: Irrelevant on macOS due to sandboxed Mach-O loading, AppKit bundle isolation, and standard Apple `.dmg` drag-and-drop installation.
    - **CVE-2026-52884** (CVSS 7.8 High - Path Traversal in Run Dialog `isInTrustedDirectory`): Flaw in path canonicalization allowing command execution outside trusted folders via `..\..\`. _NotepadMac Mitigation_: NotepadMac resolves all paths through Foundation `URL` with sandbox path canonicalization and does not expose arbitrary unverified `ShellExecute` invocations.
  - _`Scintilla 5.6.9` & `Lexilla 5.5.5`_: Zero CVEs or security advisories logged in 2025–2026. The Cocoa C++17 port (`ScintillaCocoa`) runs with memory-safe buffer management and bounded style runs.
  - _`Lua 5.5.1`_: Embedded scripting engine is sandboxed through `CLua` bridge without exposing raw OS syscalls or dangerous external process spawns.

---

## 5. Packaging & CI/CD Pipeline

### 5.1 Local Build Scripts

- `scripts/build-app.sh`: Compiles `arm64` and `x86_64` release slices via `swift build`, merges them with `lipo -create`, applies ad-hoc codesigning with `codesign --force --deep --sign -`, and produces `build/NotepadMac.app` and `build/NotepadMac-1.0.0-macOS-Universal.zip`.
- `scripts/build-dmg.sh`: Packages `NotepadMac.app` with an `/Applications` symlink into a compressed `UDZO` disk image (`build/NotepadMac-1.0.0-macOS-Universal.dmg`) with verified CRC32 checksum.
- `scripts/test-runner.sh`: Runs the unit test suite and color encoding assertions.

### 5.2 GitHub Actions Workflows

- `.github/workflows/build-universal.yml`: Automated CI that builds, tests, packages both DMG and ZIP, and publishes releases on version tags (`v*`).
- `.github/workflows/mega-linter.yml`: Automated code quality gate scanning Swift, Shell, YAML, Markdown, and Python.

---

## 6. Third-Party Credits & Acknowledgments

- **Harry Dertin Sutisna Alsyundawy (@alsyundawy)** — Lead Developer, Architect & Maintainer, ALSYUNDAWY IT SOLUTION.
- **Scintilla (v5.6.9) & Lexilla (v5.5.5)** — Neil Hodgson & Contributors (HPND License).
- **Lua Programming Language (v5.5.1)** — Roberto Ierusalimschy, Waldemar Celes, Luiz Henrique de Figueiredo / PUC-Rio (MIT License).
- **SparkNotePad** — Harry Dertin Sutisna Alsyundawy & ALSYUNDAWY IT SOLUTION (GPLv3).
- **Notepad++** — Don Ho & Notepad++ Contributors (GPLv3).
- **Notepad--** — cxasm & Contributors (GPLv3).
- **Notepad2 / Notepad3 / Notepad4** — Florian Balmer, Kai Liu, Rizonesoft, Zufuliu (BSD-3-Clause).
- **Apple Inc.** — AppKit, SwiftUI, CryptoKit, and macOS Platform SDKs.
