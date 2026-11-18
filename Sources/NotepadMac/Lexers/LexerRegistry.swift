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

public struct LanguageDefinition: Identifiable, Hashable {
    public let id: String
    public let displayName: String
    public let lexerID: String
    public let fileExtensions: [String]
    public let keywords: String
    public let isFoldable: Bool

    public var name: String { displayName }

    public init(
        id: String,
        displayName: String,
        lexerID: String,
        fileExtensions: [String],
        keywords: String = "",
        isFoldable: Bool = true
    ) {
        self.id = id
        self.displayName = displayName
        self.lexerID = lexerID
        self.fileExtensions = fileExtensions
        self.keywords = keywords
        self.isFoldable = isFoldable
    }
}

public struct LanguageGroup: Identifiable, Hashable {
    public var id: String { letter }
    public let letter: String
    public let languages: [LanguageDefinition]

    public init(letter: String, languages: [LanguageDefinition]) {
        self.letter = letter
        self.languages = languages
    }
}

public final class LexerRegistry {
    public static let shared = LexerRegistry()

    public let languages: [LanguageDefinition]

    public var plainTextLanguage: LanguageDefinition {
        languages.first(where: { $0.id == "plain_text" }) ?? LexerRegistry.langPlainText
    }

    public var alphabeticalLanguages: [LanguageDefinition] {
        languages.sorted {
            $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
    }

    public var alphabeticalGroups: [LanguageGroup] {
        let nonPlain = languages.filter { $0.id != "plain_text" }
        let grouped = Dictionary(grouping: nonPlain) { lang -> String in
            String(lang.displayName.prefix(1).uppercased())
        }
        return grouped.keys.sorted().map { letter in
            let sortedLangs = (grouped[letter] ?? []).sorted {
                $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
            }
            return LanguageGroup(letter: letter, languages: sortedLangs)
        }
    }

    private init() {
        self.languages = LexerRegistry.buildLanguageList()
    }

    public func language(forExtension ext: String) -> LanguageDefinition {
        let cleanExt = ext.lowercased().trimmingCharacters(
            in: CharacterSet(charactersIn: ".")
        )
        for lang in languages where lang.fileExtensions.contains(cleanExt) {
            return lang
        }
        return plainTextLanguage
    }

    public func detectLanguage(forFilename filename: String, content: String = "") -> LanguageDefinition {
        let nsFilename = (filename as NSString)
        let ext = nsFilename.pathExtension
        if !ext.isEmpty {
            let found = language(forExtension: ext)
            if found.id != "plain_text" {
                return found
            }
        }

        // Special exact filename handling
        let lowerName = filename.lowercased()
        if lowerName == "makefile" || lowerName == "gnumakefile" {
            return language(forId: "makefile")
        }
        if lowerName == "dockerfile" {
            return language(forId: "dockerfile")
        }
        if lowerName == "cmakelists.txt" {
            return language(forId: "cmake")
        }

        // Content-based heuristic inspection (shebangs and markup tags)
        if !content.isEmpty {
            let firstLine = content.components(separatedBy: .newlines).first?.trimmingCharacters(in: .whitespaces) ?? ""
            if firstLine.hasPrefix("#!") {
                if firstLine.contains("bash") || firstLine.contains("sh") || firstLine.contains("zsh") {
                    return language(forId: "bash")
                }
                if firstLine.contains("python") {
                    return language(forId: "python")
                }
                if firstLine.contains("node") || firstLine.contains("javascript") {
                    return language(forId: "javascript")
                }
                if firstLine.contains("perl") {
                    return language(forId: "perl")
                }
                if firstLine.contains("ruby") {
                    return language(forId: "ruby")
                }
                if firstLine.contains("lua") {
                    return language(forId: "lua")
                }
            }

            if firstLine.hasPrefix("<?php") {
                return language(forId: "php")
            }
            if firstLine.hasPrefix("<?xml") {
                return language(forId: "xml")
            }
            if firstLine.lowercased().contains("<!doctype html") || firstLine.lowercased().contains("<html") {
                return language(forId: "html")
            }
        }

        return plainTextLanguage
    }

    public func language(forId id: String) -> LanguageDefinition {
        return languages.first(where: { $0.id == id }) ?? plainTextLanguage
    }
}
