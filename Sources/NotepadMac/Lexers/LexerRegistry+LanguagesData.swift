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
    static let langJavaScript = LanguageDefinition(
        id: "javascript",
        displayName: "JavaScript / TypeScript",
        lexerID: "cpp",
        fileExtensions: ["js", "jsx", "ts", "tsx", "mjs", "cjs"],
        keywords: (
            "function var let const return if else switch case default for in " +
            "of while do break continue try catch finally throw new typeof " +
            "instanceof void delete import export from default async await " +
            "class extends super this true false null undefined interface type " +
            "enum namespace readonly declare abstract satisfies as"
        ),
        isFoldable: true
    )

    static let langHtml = LanguageDefinition(
        id: "html",
        displayName: "HTML",
        lexerID: "hypertext",
        fileExtensions: ["html", "htm", "xhtml"],
        keywords: (
            "!doctype a abbr address area article aside audio b base bdi bdo " +
            "blockquote body br button canvas caption cite code col colgroup " +
            "data datalist dd del details dfn dialog div dl dt em embed " +
            "fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head " +
            "header hr html i iframe img input ins kbd label legend li link " +
            "main map mark meta meter nav noscript object ol optgroup option " +
            "output p param picture pre progress q rb rp rt rtc ruby s samp " +
            "script section select small source span strong style sub summary " +
            "sup table tbody td template textarea tfoot th thead time title " +
            "tr track u ul var video wbr"
        ),
        isFoldable: true
    )

    static let langCss = LanguageDefinition(
        id: "css",
        displayName: "CSS / SCSS / Less",
        lexerID: "css",
        fileExtensions: ["css", "scss", "sass", "less"],
        keywords: (
            "color background margin padding border font display position " +
            "width height top left right bottom z-index opacity flex grid " +
            "transform transition animation overflow box-shadow border-radius " +
            "content cursor align-items justify-content"
        ),
        isFoldable: true
    )

    static let langPhp = LanguageDefinition(
        id: "php",
        displayName: "PHP",
        lexerID: "hypertext",
        fileExtensions: [
            "php", "phtml", "php3", "php4", "php5", "php7", "php8"
        ],
        keywords: (
            "echo print if else elseif while do for foreach as break " +
            "continue switch case default break return require include " +
            "require_once include_once function class public protected " +
            "private static final abstract interface implements extends " +
            "const new clone try catch finally throw trait namespace use " +
            "global var null true false"
        ),
        isFoldable: true
    )

    static let langRuby = LanguageDefinition(
        id: "ruby",
        displayName: "Ruby",
        lexerID: "ruby",
        fileExtensions: ["rb", "rake", "gemspec", "ru"],
        keywords: (
            "BEGIN END alias and begin break case class def defined? do " +
            "else elsif end ensure false for if in module next nil not or " +
            "redo rescue retry return self super then true undef unless " +
            "until when while yield"
        ),
        isFoldable: true
    )

    static let langPerl = LanguageDefinition(
        id: "perl",
        displayName: "Perl",
        lexerID: "perl",
        fileExtensions: ["pl", "pm", "t"],
        keywords: (
            "my our local sub if unless else elsif while until for " +
            "foreach do continue return last next redo goto use require " +
            "package format"
        ),
        isFoldable: true
    )

    static let langBash = LanguageDefinition(
        id: "bash",
        displayName: "Shell / Bash / Zsh",
        lexerID: "bash",
        fileExtensions: [
            "sh", "bash", "zsh", "command", "profile", "bashrc", "zshrc"
        ],
        keywords: (
            "if then else elif fi case esac for select while until do done " +
            "in function time declare typeset local readonly export return " +
            "exit trap shift test eval exec source alias unalias true false " +
            "echo printf"
        ),
        isFoldable: true
    )

    static let langPowerShell = LanguageDefinition(
        id: "powershell",
        displayName: "PowerShell",
        lexerID: "powershell",
        fileExtensions: ["ps1", "psm1", "psd1"],
        keywords: (
            "begin break catch class continue data do dynamicparam else " +
            "elseif end exit filter finally for foreach from function if " +
            "in inlinescript param process return switch throw trap try " +
            "until using virtual while workflow parallel sequence inline"
        ),
        isFoldable: true
    )

    static let langBatch = LanguageDefinition(
        id: "batch",
        displayName: "Batch / Windows CMD",
        lexerID: "batch",
        fileExtensions: ["bat", "cmd"],
        keywords: (
            "echo rem set if else goto call exit pause for in do choice " +
            "cls cd md rd del copy move type"
        ),
        isFoldable: false
    )

    static let langJava = LanguageDefinition(
        id: "java",
        displayName: "Java",
        lexerID: "cpp",
        fileExtensions: ["java", "jav"],
        keywords: (
            "abstract assert boolean break byte case catch char class const " +
            "continue default do double else enum extends final finally " +
            "float for goto if implements import instanceof int interface " +
            "long native new package private protected public return short " +
            "static strictfp super switch synchronized this throw throws " +
            "transient try void volatile while true false null record " +
            "sealed permits var yield"
        ),
        isFoldable: true
    )

    static let langCsharp = LanguageDefinition(
        id: "csharp",
        displayName: "C#",
        lexerID: "cpp",
        fileExtensions: ["cs"],
        keywords: (
            "abstract as base bool break byte case catch char checked class " +
            "const continue decimal default delegate do double else enum event " +
            "explicit extern false finally fixed float for foreach goto if " +
            "implicit in int interface internal is lock long namespace new " +
            "null object operator out override params private protected " +
            "public readonly ref return sbyte sealed short sizeof " +
            "stackalloc static string struct switch this throw true try " +
            "typeof uint ulong unchecked unsafe ushort using virtual void " +
            "volatile while async await var record init"
        ),
        isFoldable: true
    )

    static let langSql = LanguageDefinition(
        id: "sql",
        displayName: "SQL",
        lexerID: "sql",
        fileExtensions: ["sql", "ddl", "dml"],
        keywords: (
            "select from where insert into update delete join left right inner " +
            "outer full group by order having limit offset create table drop " +
            "alter add constraint primary key foreign references default " +
            "check unique index view trigger procedure function begin end " +
            "commit rollback union all as and or not in is null between like " +
            "case when then else distinct exists"
        ),
        isFoldable: true
    )

    static let langXml = LanguageDefinition(
        id: "xml",
        displayName: "XML",
        lexerID: "xml",
        fileExtensions: [
            "xml", "plist", "svg", "xsd", "xsl", "pom", "rss", "atom"
        ],
        keywords: "",
        isFoldable: true
    )

    static let langJson = LanguageDefinition(
        id: "json",
        displayName: "JSON",
        lexerID: "json",
        fileExtensions: ["json", "json5", "jsonl", "geojson"],
        keywords: "true false null",
        isFoldable: true
    )

    static let langYaml = LanguageDefinition(
        id: "yaml",
        displayName: "YAML",
        lexerID: "yaml",
        fileExtensions: ["yml", "yaml"],
        keywords: "true false yes no null on off",
        isFoldable: true
    )

    static let langToml = LanguageDefinition(
        id: "toml",
        displayName: "TOML",
        lexerID: "toml",
        fileExtensions: ["toml", "tml"],
        keywords: "true false",
        isFoldable: true
    )

    static let langMarkdown = LanguageDefinition(
        id: "markdown",
        displayName: "Markdown",
        lexerID: "markdown",
        fileExtensions: ["md", "markdown", "mdown", "mkd"],
        keywords: "",
        isFoldable: true
    )

    static let langDiff = LanguageDefinition(
        id: "diff",
        displayName: "Diff / Patch",
        lexerID: "diff",
        fileExtensions: ["diff", "patch"],
        keywords: "",
        isFoldable: true
    )

    static let langMakefile = LanguageDefinition(
        id: "makefile",
        displayName: "Makefile",
        lexerID: "makefile",
        fileExtensions: ["mk", "make", "makefile", "GNUmakefile"],
        keywords: (
            "include define endef ifeq ifneq ifdef ifndef else endif " +
            "override export unexport vpath"
        ),
        isFoldable: true
    )

    static let langCmake = LanguageDefinition(
        id: "cmake",
        displayName: "CMake",
        lexerID: "cmake",
        fileExtensions: ["cmake", "CMakeLists.txt"],
        keywords: (
            "cmake_minimum_required project add_executable add_library " +
            "target_link_libraries target_include_directories set " +
            "find_package message if else elseif endif foreach endforeach " +
            "while endwhile function endfunction macro endmacro return"
        ),
        isFoldable: true
    )

    static let langProps = LanguageDefinition(
        id: "props",
        displayName: "Properties / INI / Config",
        lexerID: "props",
        fileExtensions: ["ini", "conf", "cfg", "properties", "prefs"],
        keywords: "",
        isFoldable: true
    )
}
