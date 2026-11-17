# Specification: NotepadMac

## 1. Objective

NotepadMac is a production-ready, high-performance native macOS text editor combining the power of the Scintilla Cocoa editing engine + Lexilla syntax highlighters with a modern SwiftUI chrome and embedded Lua 5.5.1 scripting.

Target audience: Developers, sysadmins, writers, and power users who want a lightweight, lightning-fast, native macOS alternative to Notepad++ and standard text editors with zero electron overhead.

## 2. Tech Stack & Requirements

- **Platform**: macOS 11.0 (Big Sur) and later
- **Architecture**: Universal binary (`arm64` Apple Silicon + `x86_64` Intel)
- **Language**: Swift 5.9+ / 6.x, Objective-C++ (C++17)
- **Editor Core**: Scintilla 5.6.9 (Cocoa port) + Lexilla 5.5.5
- **Scripting Engine**: Embedded Lua 5.5.1 via native `CLua`
- **UI Framework**: SwiftUI (Chrome, Toolbar, Tab Bar, Status Bar, Settings, Lua Console) + AppKit (`NSViewRepresentable` bridge)
- **Build System**: Swift Package Manager + Shell packaging script for universal `.app` bundle, `.zip`, and `.dmg`

## 3. Supported Languages & Lexers (30+ Languages)

1. Plain Text (`LexNull` / default)
2. Lua (`LexLua` with Lua 5.5.1 keywords)
3. Python (`LexPython`)
4. Swift (`LexCPP` with Swift keyword profile)
5. C / C++ (`LexCPP`)
6. Objective-C / C++ (`LexCPP`)
7. Rust (`LexRust`)
8. Go (`LexCPP`)
9. Zig (`LexZig`)
10. JavaScript / TypeScript (`LexCPP` with JS/TS profile)
11. HTML (`LexHTML`)
12. CSS / SCSS / Less (`LexCSS`)
13. PHP (`LexHTML`)
14. Ruby (`LexRuby`)
15. Perl (`LexPerl`)
16. Shell / Bash / Zsh (`LexBash`)
17. PowerShell (`LexPowerShell`)
18. Batch (`LexBatch`)
19. Java (`LexCPP`)
20. C# (`LexCPP`)
21. SQL (`LexSQL`)
22. XML / Plist / SVG (`LexXML`)
23. JSON / JSON5 / GeoJSON (`LexJSON`)
24. YAML (`LexYAML`)
25. TOML (`LexTOML`)
26. Markdown (`LexMarkdown`)
27. Diff / Patch (`LexDiff`)
28. Makefile (`LexMakefile`)
29. CMake (`LexCMake`)
30. Properties / INI / Config (`LexProps`)

## 4. Built-in Editor Themes (7 Themes)

1. **SparkNotePad Light** (Clean macOS native light)
2. **SparkNotePad Dark** (Modern macOS dark)
3. **One Dark Pro** (NotepadMac default dark - background `#282c34`, toolbar `#21252b`)
4. **Dracula** (High-contrast dark - background `#282a36`)
5. **Monokai** (Classic dark - background `#272822`)
6. **GitHub Light** (Clean modern light - background `#ffffff`)
7. **Solarized Light** (Warm reader light - background `#fdf6e3`)

## 5. UI Architecture & Components

- **Toolbar**: Permanent dark toolbar (`#21252b`) with action buttons (New, Open, Save, Save As, Undo, Redo, Cut, Copy, Paste, Find, Word Wrap, Zoom In, Zoom Out, Lua Console, Settings).
- **Tab Bar**: Custom multi-tab bar with close buttons, modified indicator dot, file type icons, color tags, and active tab highlighting.
- **Editor Area**: `NSViewRepresentable` wrapping `ScintillaView` with line numbers, code folding margin, multi-cursor editing, brace matching, selection highlights, and native right-click context menu.
- **Find & Replace Bar**: Collapsible in-window search bar with Match Case, Whole Word, Regular Expression, Find Next/Prev, Replace, and Replace All driving native Scintilla search primitives.
- **Status Bar**: Clean bottom bar showing Cursor Line & Column, Selection length, Total Lines, Encoding (UTF-8/UTF-16/ASCII), Line Endings (LF/CRLF/CR), and Active Lexer.
- **Preferences Window**: Tabbed preferences for General, Editor (font, font size, tab width, word wrap, line numbers, folding), Themes, and Lua Scripting.
- **About Window**: Modern macOS modal sheet showcasing application version, Mach-O Universal architecture badge, engine versions, feature highlights, and GitHub link.
- **Lua Scripting Console**: Floating panel / sheet providing an interactive scripting console, execution history, script evaluation, and editor automation API (`editor.getText()`, `editor.setText()`, `editor.getSelection()`, `editor.replaceSelection()`, etc.).

## 6. Commands

- Build Debug: `swift build`
- Build Release (Native): `swift build -c release`
- Build Universal Binary (arm64 + x86_64) & Create App Bundle + ZIP: `./scripts/build-app.sh`
- Package Universal DMG Disk Image: `./scripts/build-dmg.sh`
- Run Tests: `./scripts/test-runner.sh`

## 7. Boundaries & Invariants

- **Always**: Ensure memory safety, check null pointers in C++ bridges, keep ScintillaView notifications on the main thread, run linters and syntax checks before committing.
- **Never**: Use web views or electron for text editing; never block the main thread during file I/O or Lua execution.
- **Success Criteria**: Zero compiler warnings on Swift 5.9+, clean universal binary produced for arm64 + x86_64, all 30+ languages highlighting correctly, Lua console executing script automation, clean git repository pushed to `https://github.com/alsyundawy/NotepadMac`.
