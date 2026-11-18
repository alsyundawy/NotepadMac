// swift-tools-version: 5.9

/*
 *
 * This file is part of NotepadMac.
 *
 * Copyright 2025-2026 Harry Dertin Sutisna Alsyundawy <alsyundawy@gmail.com>
 * https://github.com/alsyundawy/NotepadMac
 * ALSYUNDAWY IT SOLUTION <https://alsyundawy.com>
 *
 * NotepadMac is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * NotepadMac is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with NotepadMac.  If not, see <https://www.gnu.org/licenses/>.
 */

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
