# Implementation Plan: NotepadMac

## Architecture Overview

NotepadMac is structured in three clear architectural layers:

1. **Core Engine Layer (C++17 / Objective-C++)**:
   - `ScintillaCocoa`: Official Scintilla 5.6.9 Cocoa engine (`ScintillaView`, `ScintillaCocoa`, `PlatCocoa`, `CellBuffer`, `Editor`, etc.)
   - `LexillaCore`: Official Lexilla 5.5.5 syntax lexers (`LexCPP`, `LexMarkdown`, `LexPython`, `LexBash`, `LexHTML`, `LexYAML`, `LexNull`, etc.)
   - Clean bridging header exposing `ScintillaView` and Scintilla message constants to Swift.
2. **Bridge & Scripting Layer (Swift 6.x / Swift 5.9+)**:
   - `ScintillaEditorRepresentable`: `NSViewRepresentable` wrapping `ScintillaView` for SwiftUI.
   - `ScintillaEditorCoordinator`: Delegate coordinator managing Scintilla notifications, keyboard shortcuts, and document updates.
   - `LuaEngine`: Scripting service embedding official Lua 5.5.1 via native `CLua` C-bridge.
   - `LexerRegistry`: Maps file extensions and user selections to Lexilla lexers and style rules across 30+ languages.
   - `Theme`: Maps theme color definitions to Scintilla style slots and SwiftUI views.
3. **User Interface Chrome (SwiftUI 11.0+)**:
   - `DocumentManager`: Observable state handling open tabs, unsaved states, active documents, and search queries.
   - `NotepadToolbar`: Permanent dark `#21252b` toolbar with high-productivity actions and tooltips.
   - `NotepadTabBar`: Custom tab bar with close buttons, modified markers, file badges, and color tags.
   - `FindReplaceBar`: Search and replace bar supporting regex, case sensitivity, and whole words driving Scintilla natively.
   - `NotepadStatusBar`: Live status bar displaying line/col, encoding, line ending, and lexer.
   - `PreferencesView`: Preferences panel for fonts, themes, tabs, and scripting.
   - `AboutView`: Modern macOS modal sheet showcasing engine badges, architecture, and features.
   - `LuaConsoleSheet`: Interactive scripting runner and console.

## Execution Order

1. Setup package structure (`Package.swift`, source folders, gitignore, licenses).
2. Integrate Scintilla 5.6.9 and Lexilla 5.5.5 source files with C++17 compilation and bridging header.
3. Integrate official Lua 5.5.1 via native `CLua` module.
4. Implement theme engine and 7 developer themes.
5. Implement lexer configuration for 30+ languages.
6. Implement `ScintillaEditorRepresentable` and `DocumentManager`.
7. Build SwiftUI Chrome (Toolbar, Tab bar, Find/Replace bar, Status bar, Preferences, Lua Console, About View).
8. Implement Universal Binary build scripts (`build-app.sh` and `build-dmg.sh`).
9. Verify universal binary (`arm64` + `x86_64`) with `lipo` and verify all features.
10. Setup CI/CD with MegaLinter, CodeQL, and Universal Build GitHub Actions.
