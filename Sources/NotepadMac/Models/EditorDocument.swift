//
//  EditorDocument.swift
//  NotepadMac
//
//  Model representing an open text document tab in NotepadMac
//

import Foundation
import SwiftUI

public enum LineEnding: String, CaseIterable, Identifiable {
    case unixLF = "Unix (LF)"
    case windowsCRLF = "Windows (CRLF)"
    case macCR = "Mac (CR)"

    public var id: String { rawValue }

    public var separator: String {
        switch self {
        case .unixLF: return "\n"
        case .windowsCRLF: return "\r\n"
        case .macCR: return "\r"
        }
    }

    public static func detect(in text: String) -> LineEnding {
        if text.contains("\r\n") {
            return .windowsCRLF
        } else if text.contains("\n") {
            return .unixLF
        } else if text.contains("\r") {
            return .macCR
        }
        return .unixLF
    }
}

public final class EditorDocument: Identifiable, ObservableObject, Hashable {
    public let id: UUID
    @Published public var title: String
    @Published public var fileURL: URL?
    @Published public var content: String {
        didSet {
            if oldValue != content {
                isModified = true
            }
        }
    }
    @Published public var isModified: Bool
    @Published public var isReadOnly: Bool
    @Published public var encoding: String.Encoding
    @Published public var lineEnding: LineEnding
    @Published public var language: LanguageDefinition
    @Published public var cursorLine: Int
    @Published public var cursorColumn: Int
    @Published public var selectionLength: Int
    @Published public var zoomOffset: Int
    @Published public var tagColorHex: String?

    public init(
        id: UUID = UUID(),
        title: String = "Untitled",
        fileURL: URL? = nil,
        content: String = "",
        isModified: Bool = false,
        isReadOnly: Bool = false,
        encoding: String.Encoding = .utf8,
        lineEnding: LineEnding = .unixLF,
        language: LanguageDefinition = LexerRegistry.shared.plainTextLanguage,
        cursorLine: Int = 1,
        cursorColumn: Int = 1,
        selectionLength: Int = 0,
        zoomOffset: Int = 0,
        tagColorHex: String? = nil
    ) {
        self.id = id
        self.title = title
        self.fileURL = fileURL
        self.content = content
        self.isModified = isModified
        self.isReadOnly = isReadOnly
        self.encoding = encoding
        self.lineEnding = lineEnding
        self.language = language
        self.cursorLine = cursorLine
        self.cursorColumn = cursorColumn
        self.selectionLength = selectionLength
        self.zoomOffset = zoomOffset
        self.tagColorHex = tagColorHex
    }

    public static func == (lhs: EditorDocument, rhs: EditorDocument) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var encodingName: String {
        switch encoding {
        case .utf8: return "UTF-8"
        case .utf16: return "UTF-16"
        case .ascii: return "ASCII"
        case .isoLatin1: return "ISO-Latin-1"
        case .macOSRoman: return "Mac Roman"
        default: return "Unicode"
        }
    }

    public var fileSizeDescription: String {
        let bytes = content.utf8.count
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024.0)
        } else {
            return String(format: "%.1f MB", Double(bytes) / (1024.0 * 1024.0))
        }
    }

    public var lineCount: Int {
        if content.isEmpty { return 1 }
        return content.components(separatedBy: "\n").count
    }
}
