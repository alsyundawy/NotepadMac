// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NotepadMac",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "NotepadMac",
            targets: ["NotepadMac"]
        ),
        .library(
            name: "ScintillaCocoa",
            targets: ["ScintillaCocoa"]
        ),
        .library(
            name: "CLua",
            targets: ["CLua"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CLua",
            path: "Sources/CLua",
            publicHeadersPath: "include",
            cSettings: [
                .define("LUA_USE_MACOSX"),
                .headerSearchPath("include")
            ]
        ),
        .target(
            name: "ScintillaCocoa",
            path: "Sources/ScintillaCocoa",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
                .headerSearchPath("src"),
                .headerSearchPath("cocoa"),
                .headerSearchPath("lexilla/include"),
                .headerSearchPath("lexilla/lexlib"),
                .headerSearchPath("lexilla/src"),
                .define("SCI_NAMESPACE"),
                .define("SCINTILLA_QT", to: "0")
            ],
            cxxSettings: [
                .headerSearchPath("include"),
                .headerSearchPath("src"),
                .headerSearchPath("cocoa"),
                .headerSearchPath("lexilla/include"),
                .headerSearchPath("lexilla/lexlib"),
                .headerSearchPath("lexilla/src"),
                .define("SCI_NAMESPACE"),
                .define("SCINTILLA_QT", to: "0"),
                .unsafeFlags(["-fobjc-arc"])
            ]
        ),
        .executableTarget(
            name: "NotepadMac",
            dependencies: [
                "ScintillaCocoa",
                "CLua"
            ],
            path: "Sources/NotepadMac"
        ),
        .testTarget(
            name: "NotepadMacTests",
            dependencies: [
                "NotepadMac",
                "ScintillaCocoa",
                "CLua"
            ],
            path: "Tests/NotepadMacTests"
        )
    ],
    cxxLanguageStandard: .cxx17
)
