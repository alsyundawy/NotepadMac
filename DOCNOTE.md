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

### 3.3 Modernized Find, Replace & Mark Hub (`FindReplaceDialogView` & `FindReplaceBar`)

- **Design Harmony with Tools Hub**: Completely redesigned with the exact same visual architecture, geometry, and styling tokens as `ToolsDialogView`:
  - Uniform window background (`Color(NSColor.windowBackgroundColor)`), 12pt continuous corner radii, and matching header/footer bars (`Color(NSColor.controlBackgroundColor)`).
  - Native segmented tab selector seamlessly switching between **Find**, **Replace**, and **Mark** tabs.
  - Comfortable, non-cramped fixed frame dimensions (`660x490`) eliminating jarring height jumps.
- **Dedicated Mark & Bookmark Engine**:
  - Full support for Notepad++-style buffer marking and margin bookmarking.
  - **Mark All**: Highlights all matches across the buffer using Scintilla Indicator 8 (`INDIC_ROUNDBOX`) and dynamically adds rounded bookmark markers (Marker 20) in margin 1.
  - **Clear All Marks**: Flushes indicator highlights and removes bookmark markers (`SCI_MARKERDELETEALL`).
  - **Copy Marked Text**: Automatically extracts all bookmarked/marked lines and commits them to the macOS system pasteboard.
  - Attribute toggles: **Bookmark Line** (`🔖`) and **Purge for each search** (`🧹`).
- **Modernized Inline Search Bar (`FindReplaceBar`)**:
  - Modernized with full localization (`loc(...)`), clean text fields with clear buttons, quick option toggles (`Aa`, `\b`, `.*`, `↩`), navigation buttons, occurrence counting, status pills, and one-click expand to the full dialog hub.

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

### 3.8 Bilingual Localization Subsystem (`LocalizationManager`)

- Centralized `ObservableObject` handling dynamic runtime language switching between **English** and **Bahasa Indonesia** (`id`).
- Persists user language preference in `UserDefaults` (`notepad_app_language`) with fallback to macOS system preferred languages.
- Provides immediate reactivity across SwiftUI menus, buttons, status bars, and modal dialogs via `loc(key)` helper.

### 3.9 Check for Updates Subsystem (`CheckUpdateDialogView`)

- Connects to GitHub Releases REST API (`https://api.github.com/repos/alsyundawy/NotepadMac/releases/latest`) with custom User-Agent and 5-second connection timeout.
- Gracefully handles rate-limiting and offline scenarios with safe local status fallback.

### 3.10 Unsaved Changes Protection Subsystem (Data Loss Prevention Guard)

- **Native Confirmation Dialog**: Implemented `confirmCloseDocument(_:window:) -> Bool` in `DocumentManager` displaying a native macOS `NSAlert` modal whenever an unsaved / modified buffer is targeted for closure or termination.
- **Apple HIG-Compliant Action Buttons**:
  - **Save** (Primary / Return key `\r`): Commits changes to the existing file URL, or presents a modal `NSSavePanel` (`promptSaveAsModal(for:window:)`) for untitled documents. Returns `true` on successful write, or `false` if cancelled.
  - **Cancel** (Escape key `\u{1b}`): Aborts the close / quit operation immediately, leaving the tab, window, and application state intact. Returns `false`.
  - **Don't Save** (Command-D `⌘D`): Discards unsaved modifications without writing to disk and returns `true`, proceeding with tab or window closure.
- **Active Tab Focus**: Before presenting the confirmation alert, `activeDocumentId` is automatically switched to the affected document, ensuring the user visually inspects the exact modified buffer before making a decision.
- **Tab Lifecycle Interception**: Guarded inside all document-closing workflows:
  - `closeDocument(id:)`
  - `closeOtherDocuments(except:)`
  - `closeTabsToTheRight(of:)`
  - `closeAllDocuments()`
- **Window Close Interception**: `AppDelegate` conforms to `NSWindowDelegate` and implements `windowShouldClose(_ sender: NSWindow) -> Bool`. It iterates over all opened modified documents and prompts confirmation before allowing the window to close.
- **Application Quit Interception**: `AppDelegate` implements `applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply`. If any open document has unsaved modifications, it sequentially requests user confirmation. Returning `.terminateCancel` cleanly prevents macOS from killing the app process if the user cancels.
- **Bilingual Localization**: Added localized strings (`save_changes_title`, `save_changes_message`, `dont_save`) in `LocalizationManager` for both English and Indonesian.

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

### 4.1 Local Build Scripts

- `scripts/build-app.sh`: Compiles `arm64` and `x86_64` release slices via `swift build`, merges them with `lipo -create`, applies ad-hoc codesigning with `codesign --force --deep --sign -`, and produces `build/NotepadMac.app` and `build/NotepadMac-1.0.0-macOS-Universal.zip`.
- `scripts/build-dmg.sh`: Packages `NotepadMac.app` with an `/Applications` symlink into a compressed `UDZO` disk image (`build/NotepadMac-1.0.0-macOS-Universal.dmg`).
- `scripts/test-runner.sh`: Runs the unit test suite and color encoding assertions.

### 4.2 GitHub Actions Workflows

- `.github/workflows/build-universal.yml`: Automated CI that builds, tests, packages both DMG and ZIP, and publishes releases on version tags (`v*`).
- `.github/workflows/mega-linter.yml`: Automated code quality gate scanning Swift, Shell, YAML, Markdown, and Python.
