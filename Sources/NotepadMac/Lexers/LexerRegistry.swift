//
//  LexerRegistry.swift
//  NotepadMac
//
//  Language and Lexilla lexer mapping definitions
//

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

    public func language(forId id: String) -> LanguageDefinition {
        return languages.first(where: { $0.id == id }) ?? plainTextLanguage
    }
}
