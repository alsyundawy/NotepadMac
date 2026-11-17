# Task List: NotepadMac

- [x] Task 1: Setup Package Structure & Build Manifests
  - Acceptance: `Package.swift`, `.gitignore`, `LICENSE`, `README.md` created with proper targets
  - Verify: `swift package describe` succeeds
  - Files: `Package.swift`, `.gitignore`, `LICENSE`, `README.md`

- [x] Task 2: Integrate Scintilla Cocoa & Lexilla Core Engine
  - Acceptance: Scintilla 5.6.9 + Lexilla 5.5.5 compiled into `ScintillaCocoa` target with public Objective-C bridging headers
  - Verify: `swift build --target ScintillaCocoa` exits with code 0
  - Files: `Sources/ScintillaCocoa/**/*`

- [x] Task 3: Integrate Lua Engine & Scripting Service
  - Acceptance: Lua 5.4.7 integrated via `CLua` with `LuaEngine` exposing editor methods to Lua
  - Verify: Unit tests and runners execute Lua script and alter editor state
  - Files: `Sources/CLua/**/*`, `Sources/NotepadMac/Lua/**/*`

- [x] Task 4: Implement Scintilla Editor NSViewRepresentable & Lexer/Theme Engine
  - Acceptance: `ScintillaEditorRepresentable` bridges ScintillaView to SwiftUI with syntax highlighting and theme styling
  - Verify: Target builds and styles apply correctly to ScintillaView
  - Files: `Sources/NotepadMac/Editor/**/*`, `Sources/NotepadMac/Themes/**/*`, `Sources/NotepadMac/Lexers/**/*`

- [x] Task 5: Implement Document Management & State Architecture
  - Acceptance: Multi-document model with tab management, open/save/save as, dirty tracking
  - Verify: Document lifecycle functions correctly
  - Files: `Sources/NotepadMac/Models/**/*`

- [x] Task 6: Implement SwiftUI Chrome (Toolbar, Tab Bar, Status Bar, Find/Replace, Preferences, Lua Console)
  - Acceptance: Complete modern native macOS interface with dark `#21252b` toolbar, tabs, status bar, preferences, and Lua console
  - Verify: App target compiles without warnings
  - Files: `Sources/NotepadMac/Views/**/*`

- [x] Task 7: Universal Binary Build Script & App Bundle Packaging
  - Acceptance: `build-app.sh` script produces `NotepadMac.app` with universal binary (`arm64` + `x86_64`), Info.plist, icon
  - Verify: `file` and `lipo -info` verify universal binary Mach-O
  - Files: `scripts/build-app.sh`, `Resources/Info.plist`, `Resources/AppIcon.icns`

- [x] Task 8: 14-Pillar Review, Linters, Git & GitHub Deployment
  - Acceptance: Zero linter/compiler errors, 14 review pillars satisfied, public repository live on GitHub
  - Verify: `gh repo view alsyundawy/NotepadMac` returns 200 OK
  - Files: Whole repository
