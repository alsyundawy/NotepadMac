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

import Foundation

extension LexerRegistry {
    static func buildLanguageList() -> [LanguageDefinition] {
        let core: [LanguageDefinition] = [
            langPlainText, langLua, langPython, langSwift, langCpp,
            langObjc, langRust, langGo, langZig,
            langJavaScript, langHtml, langCss, langPhp, langRuby,
            langPerl, langBash, langPowerShell, langBatch,
            langJava, langCsharp, langSql, langXml, langJson,
            langYaml, langToml, langMarkdown, langDiff, langMakefile,
            langCmake, langProps
        ]
        return core + extendedLanguages
    }

    static let langPlainText = LanguageDefinition(
        id: "plain_text",
        displayName: "Plain Text",
        lexerID: "null",
        fileExtensions: ["txt", "text", "log", "ans", "asc"],
        keywords: "",
        isFoldable: false
    )

    static let langLua = LanguageDefinition(
        id: "lua",
        displayName: "Lua (Lua 5.5.1)",
        lexerID: "lua",
        fileExtensions: ["lua"],
        keywords: (
            "and break do else elseif end false for function goto if in local " +
            "nil not or repeat return then true until while _G _VERSION assert " +
            "collectgarbage dofile error getmetatable io ipairs load loadfile " +
            "next pairs pcall print rawequal rawget rawlen rawset require " +
            "select setmetatable string table tonumber tostring type utf8 warn " +
            "xpcall editor"
        ),
        isFoldable: true
    )

    static let langPython = LanguageDefinition(
        id: "python",
        displayName: "Python",
        lexerID: "python",
        fileExtensions: ["py", "pyw", "pyi", "pyd"],
        keywords: (
            "def class return if elif else while for in try except finally " +
            "with as import from global nonlocal lambda pass break continue " +
            "raise assert yield async await True False None and or not is " +
            "match case type"
        ),
        isFoldable: true
    )

    static let langSwift = LanguageDefinition(
        id: "swift",
        displayName: "Swift",
        lexerID: "cpp",
        fileExtensions: ["swift"],
        keywords: (
            "import func let var struct class enum protocol extension public " +
            "private internal fileprivate open override mutating init deinit " +
            "get set return if else switch case default for in while guard " +
            "defer break continue throw try catch async await actor some any " +
            "where true false nil self Self nonisolated isolated"
        ),
        isFoldable: true
    )

    static let langCpp = LanguageDefinition(
        id: "cpp",
        displayName: "C / C++",
        lexerID: "cpp",
        fileExtensions: [
            "c", "cpp", "cc", "cxx", "h", "hpp", "hxx", "c++", "h++"
        ],
        keywords: (
            "auto break case char char8_t char16_t char32_t const constexpr " +
            "consteval constinit continue default do double else enum extern " +
            "float for goto if inline int long register return short signed " +
            "sizeof static static_assert struct switch template this " +
            "thread_local typedef union unsigned void volatile while class " +
            "public protected private virtual typename namespace using new " +
            "delete true false bool nullptr override final concept requires " +
            "co_await co_return co_yield"
        ),
        isFoldable: true
    )

    static let langObjc = LanguageDefinition(
        id: "objc",
        displayName: "Objective-C / C++",
        lexerID: "cpp",
        fileExtensions: ["m", "mm"],
        keywords: (
            "@interface @implementation @end @protocol @optional @required " +
            "@property @synthesize @dynamic @class @selector @encode " +
            "@synchronized @try @catch @finally @throw @autoreleasepool " +
            "YES NO nil Nil id instancetype BOOL self super"
        ),
        isFoldable: true
    )

    static let langRust = LanguageDefinition(
        id: "rust",
        displayName: "Rust",
        lexerID: "rust",
        fileExtensions: ["rs"],
        keywords: (
            "as async await break const continue crate dyn else enum extern " +
            "false fn for if impl in let loop match mod move mut pub ref " +
            "return Self self static struct super trait true type unsafe use " +
            "where while i8 i16 i32 i64 i128 isize u8 u16 u32 u64 u128 usize " +
            "f32 f64 bool char str Option Some None Result Ok Err Vec String Box"
        ),
        isFoldable: true
    )

    static let langGo = LanguageDefinition(
        id: "go",
        displayName: "Go",
        lexerID: "cpp",
        fileExtensions: ["go"],
        keywords: (
            "break default func interface select case defer go map struct " +
            "chan else goto package switch const fallthrough if range type " +
            "continue for import return var true false iota nil bool byte " +
            "complex64 complex128 error float32 float64 int int8 int16 " +
            "int32 int64 rune string uint uint8 uint16 uint32 uint64 " +
            "uintptr any comparable"
        ),
        isFoldable: true
    )

    static let langZig = LanguageDefinition(
        id: "zig",
        displayName: "Zig",
        lexerID: "zig",
        fileExtensions: ["zig"],
        keywords: (
            "addrspace align allowzero and anyerror anyframe anytype asm " +
            "async await break catch comptime const continue defer do else " +
            "enum errdefer error export extern fn for if inline noalias " +
            "noinline nosuspend opaque or orelse packed pub resume return " +
            "struct suspend switch test threadlocal try union unreachable " +
            "usingnamespace var volatile while bool isize usize void noreturn " +
            "type anyopaque f16 f32 f64 f80 f128 c_short c_ushort c_int " +
            "c_uint c_long c_ulong c_longlong c_ulonglong c_longdouble " +
            "c_char true false null undefined"
        ),
        isFoldable: true
    )
}
