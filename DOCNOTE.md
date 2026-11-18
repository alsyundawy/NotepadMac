# NotepadMac: Technical Documentation & Architecture Notes (DOCNOTE)

## 1. System Overview

**NotepadMac** is a hybrid macOS desktop application combining high-performance native C++17 editing engines with modern SwiftUI reactive UI and embedded Lua scripting.

### Tech Stack & Version Manifest

| Component          | Version              | Language / Toolchain            | Purpose                                              |
| :----------------- | :------------------- | :------------------------------ | :--------------------------------------------------- |
| **Scintilla Core** | **5.6.9**            | C++17 / Objective-C++           | Text buffer, caret handling, undo/redo, text styling |
| **Lexilla**        | **5.5.5**            | C++17                           | 50+ syntax highlighting lexers, syntax folding       |
| **Lua Engine**     | **5.5.1**            | ISO C (via `CLua`)              | Embedded script runner, editor automation            |
| **UI Chrome**      | **macOS 11.0+**      | Swift 5.9+ / Swift 6.x          | Toolbar, TabBar, StatusBar, Menus, Panels            |
| **Architecture**   | **Universal**        | `arm64` + `x86_64`              | Native execution on Apple Silicon & Intel            |
| **License**        | **GPL-3.0-or-later** | GNU General Public License v3.0 | Copyleft protection with Scintilla/Lua credits       |

---

## 2. Architecture & Layering

```text
+-------------------------------------------------------------+
|                     SwiftUI Chrome Layer                    |
|   (NotepadToolbar, NotepadTabBar, NotepadStatusBar, ...)    |
|   (FindReplaceDialogView, PreferencesView, AboutView)       |
+-------------------------------------------------------------+
                              |
                     Swift / AppKit Bridge
                              |
+-------------------------------------------------------------+
|              ScintillaEditorCoordinator Layer               |
|  - ScintillaEditorCoordinator+Search.swift (Find / Replace) |
|  - ScintillaEditorCoordinator+ContextMenu.swift (NSMenu)    |
|  - ScintillaNotificationProtocol (2008, 2007, 2010 events)   |
+-------------------------------------------------------------+
                              |
                     C++17 / Objective-C++
                              |
+-------------------------------------------------------------+
|                    Native Engine Layer                      |
|       - ScintillaCocoa 5.6.9 (ScintillaView, PlatCocoa)     |
|       - Lexilla 5.5.5 (50+ programming language lexers)     |
|       - CLua 5.5.1 (Official C runtime & CLuaBridge)        |
+-------------------------------------------------------------+
```

---

## 3. Core Modules & Key Classes

### 3.1 Editor Bridge (`ScintillaEditorRepresentable`)

- Implements `NSViewRepresentable` to bridge AppKit `ScintillaView` into SwiftUI hierarchies.
- Maintains `isUpdatingFromScintilla` flag to break cyclical feedback loops between Scintilla buffer mutations and SwiftUI state updates.
- Attaches the custom native `NSMenu` context menu via `buildEditorContextMenu()`.

### 3.2 Search & Replace Subsystem (`ScintillaEditorCoordinator+Search`)

- Dispatches search commands directly to Scintilla's native methods:
  - `view.findAndHighlightText(...)`: Performs rapid incremental search with automatic viewport scrolling (`SCI_SCROLLCARET`) and text highlighting.
  - Continuous Replace: If the current selection matches the find query, it atomically replaces it via `SCI_REPLACESEL` (2170) and immediately triggers `findNext` so the user can replace matches continuously.
  - Bidirectional Wrap-Around: Searches wrap around smoothly from end to beginning (downward) or beginning to end (upward) in both regular and regex search modes.
  - Smart Highlighting: Utilizes Scintilla native indicator 8 (`INDIC_ROUNDBOX` 7) with warm amber gold BGR styling (`0x00A5FF`) and alpha blending (`SCI_INDICSETALPHA` 75, `SCI_INDICSETOUTLINEALPHA` 160) to automatically illuminate all matching occurrences of selected words or active queries across the document.
  - Regular expression evaluation via `SCFIND_REGEXP`, `SCFIND_MATCHCASE`, and `SCFIND_WHOLEWORD`.
  - Occurrence counting via `countMatches(in:query:matchCase:wholeWord:isRegex:)` without disrupting the user's cursor or viewport.

### 3.3 SparkNotePad-Style Dedicated Find & Replace Dialog (`FindReplaceDialogView`)

- Standalone modal sheet dialog inspired by SparkNotePad and Notepad++.
- Features tabbed navigation between "Find" and "Replace" modes.
- Search options: Match Case, Whole Word Only, Regular Expression, and Wrap Around.
- Direction controls: Up and Down radio selectors.
- Action triggers: Find Next (`Return`), Find Previous, Replace, Replace All, Count occurrences, and Close (`Esc`).

### 3.4 Text Transformations & Format Menu (`NotepadMenuCommands`)

- Relocated under `FormatMenuCommands`:
  - `UPPERCASE` (`SCI_UPPERCASE` 2341)
  - `lowercase` (`SCI_LOWERCASE` 2340)
  - `Capitalize` (Title Case via Swift string capitalization)
  - `Invert Case` (Character-by-character case inversion)
  - `Indent Selection` (`SCI_TAB` 2327) & `Outdent Selection` (`SCI_BACKTAB` 2328)
- Automatic fallback: If no selection is active, detects and transforms the word currently under the caret using `SCI_WORDSTARTPOSITION` and `SCI_WORDENDPOSITION`.

### 3.5 Expanded Lexilla Lexers & Alphabetical Submenus (`LexerRegistry`)

- Over 50 supported languages registered across `LanguagesCore`, `LanguagesData`, and `LanguagesExtended`.
- Clean alphabetical organization: Sorted and grouped into A–Z letter submenus (`alphabeticalGroups`) with "Plain Text" pinned at the top across Menu Bar, Toolbar, and Status Bar.
- Immediate Lexilla colorization: Automatically triggers `SCI_COLOURISE` (4003) on buffer load and tab switching so syntax highlighting is rendered immediately.

### 3.6 Embedded Lua 5.5.1 Runtime (`LuaEngine`)

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

### 3.7 Developer & Security Tools Suite (`Sources/NotepadMac/Tools/`)

- **`HashTools`**: Hardware-accelerated cryptographic hash functions (MD5, SHA-1, SHA-256, SHA-384, SHA-512) via Apple `CryptoKit` and standard IEEE 802.3 CRC32 with precomputed lookup table.
- **`CryptoTools`**: AES-256-GCM authenticated cipher with PBKDF2-HMAC-SHA256 key derivation (100,000 iterations, 16-byte cryptographically secure salt via `SecRandomCopyBytes`, 12-byte nonce, 16-byte authentication tag). Self-describing `NPMENC01:` container format.
- **`MimeTools`**: RFC 4648 Base64 encoding/decoding, RFC 3986 URL percent-encoding, and HTML entity sanitization.
- **`ConverterTools`**: ASCII to Hexadecimal string conversion and multi-base integer translation (Base-2, Base-8, Base-10, Base-16).
- **`DeveloperTools`**: JSON formatting with configurable 2/4-space indentation, minification, XML document validation, JWT inspection (header, claims, payload, signature, exp/iat timestamp parsing), UUID v4 generator, and ISO 8601 / Unix Epoch conversion.

### 3.8 Bilingual Localization Subsystem (`LocalizationManager`)

- Centralized `ObservableObject` handling dynamic runtime language switching between **English** and **Bahasa Indonesia** (`id`).
- Persists user language preference in `UserDefaults` (`notepad_app_language`) with fallback to macOS system preferred languages.
- Provides immediate reactivity across SwiftUI menus, buttons, status bars, and modal dialogs via `loc(key)` helper.

### 3.9 Check for Updates Subsystem (`CheckUpdateDialogView`)

- Connects to GitHub Releases REST API (`https://api.github.com/repos/alsyundawy/NotepadMac/releases/latest`) with custom User-Agent and 5-second connection timeout.
- Gracefully handles rate-limiting and offline scenarios with safe local status fallback.

---

## 4. Security & Hardening Review (2025–2026 Analysis)

- **Input Validation**: Text transformations, hex parsers, and search inputs are bounded and sanitized against buffer overflows and memory exhaustion (CWE-119 / CWE-787).
- **Safe Memory Operations**: Removed all force unwraps (`!`) in cryptographic memory buffers; replaced line-splitting arrays with zero-allocation UTF-8 byte traversal in `EditorDocument.lineCount`.
- **Mitigation of Upstream Vulnerabilities**:
  - _CVE-2025-49144 / CVE-2025-56383 (DLL / Binary Hijacking)_: Irrelevant on macOS due to sandboxed Mach-O loading and explicit bundle paths.
  - _CVE-2025-15556 (WinGUp Updater Hijacking)_: NotepadMac uses native HTTPS GitHub API for update checks without executing unverified third-party binaries.
  - _CVE-2026-25926 / CVE-2026-5525 (Path Buffer Overflows)_: macOS paths are handled dynamically via Foundation `URL` without MAX_PATH (260 byte) limits.
  - _CVE-2026-48770 / CVE-2026-48800 (Config / IPC RCE)_: NotepadMac does not use Windows IPC (`WM_COPYDATA`) or insecure XML deserialization; configuration is managed through Swift type-safe models.

---

## 5. Packaging & CI/CD Pipeline

### 4.1 Local Build Scripts

- `scripts/build-app.sh`: Compiles `arm64` and `x86_64` release slices via `swift build`, merges them with `lipo -create`, applies ad-hoc codesigning with `codesign --force --deep --sign -`, and produces `build/NotepadMac.app` and `build/NotepadMac-1.0.0-macOS-Universal.zip`.
- `scripts/build-dmg.sh`: Packages `NotepadMac.app` with an `/Applications` symlink into a compressed `UDZO` disk image (`build/NotepadMac-1.0.0-macOS-Universal.dmg`).
- `scripts/test-runner.sh`: Runs the unit test suite and color encoding assertions.

### 4.2 GitHub Actions Workflows

- `.github/workflows/build-universal.yml`: Automated CI that builds, tests, packages both DMG and ZIP, and publishes releases on version tags (`v*`).
- `.github/workflows/mega-linter.yml`: Automated code quality gate scanning Swift, Shell, YAML, Markdown, and Python.
