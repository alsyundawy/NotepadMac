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

import AppKit
import Foundation
import ScintillaCocoa

extension ScintillaEditorCoordinator {
    func registerSearchObservers(center: NotificationCenter) {
        observers.append(center.addObserver(
            forName: .notepadFindNext,
            object: nil,
            queue: .main
        ) { [weak self] notif in
            self?.handleFind(notif: notif, backwards: false)
        })

        observers.append(center.addObserver(
            forName: .notepadFindPrevious,
            object: nil,
            queue: .main
        ) { [weak self] notif in
            self?.handleFind(notif: notif, backwards: true)
        })

        observers.append(center.addObserver(
            forName: .notepadReplaceNext,
            object: nil,
            queue: .main
        ) { [weak self] notif in
            self?.handleReplaceNext(notif: notif)
        })

        observers.append(center.addObserver(
            forName: .notepadReplaceAll,
            object: nil,
            queue: .main
        ) { [weak self] notif in
            self?.handleReplaceAll(notif: notif)
        })

        observers.append(center.addObserver(
            forName: .notepadCountOccurrences,
            object: nil,
            queue: .main
        ) { [weak self] notif in
            self?.handleCount(notif: notif)
        })

        observers.append(center.addObserver(
            forName: .notepadUseSelectionForFind,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleUseSelectionForFind()
        })
    }

    // MARK: - Smart Highlighting (Indicator 8)

    func setupHighlightIndicator() {
        guard let view = scintillaView else { return }
        // Indicator 8: INDIC_ROUNDBOX (7)
        view.message(UInt32(2080), wParam: 8, lParam: 7)
        // Indicator color: warm amber gold 0x00A5FF (BGR)
        view.message(UInt32(2082), wParam: 8, lParam: 0x00A5FF)
        // Alpha fill: 75 / 255
        view.message(UInt32(2523), wParam: 8, lParam: 75)
        // Outline alpha: 160 / 255
        view.message(UInt32(2558), wParam: 8, lParam: 160)
        // Draw under text
        view.message(UInt32(2510), wParam: 8, lParam: 1)
    }

    func clearHighlights() {
        guard let view = scintillaView else { return }
        let len = view.message(UInt32(2183)) // SCI_GETTEXTLENGTH
        guard len > 0 else { return }
        view.message(UInt32(2500), wParam: 8) // SCI_SETINDICATORCURRENT
        view.message(UInt32(2505), wParam: 0, lParam: len) // SCI_INDICATORCLEARRANGE
    }

    func highlightOccurrences(of needle: String, matchCase: Bool) {
        guard let view = scintillaView else { return }
        clearHighlights()
        let trimmed = needle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count >= 2, trimmed.count <= 120 else { return }
        let docLen = view.message(UInt32(2183))
        guard docLen > 0 else { return }

        var flags: UInt = 0
        if matchCase { flags |= 0x4 } // SCFIND_MATCHCASE

        view.message(UInt32(2198), wParam: flags) // SCI_SETSEARCHFLAGS
        view.message(UInt32(2500), wParam: 8) // SCI_SETINDICATORCURRENT

        var targetStart = 0
        let needleByteCount = trimmed.utf8.count

        trimmed.withCString { cStr in
            while targetStart < docLen {
                view.message(UInt32(2190), wParam: UInt(targetStart)) // SCI_SETTARGETSTART
                view.message(UInt32(2192), wParam: UInt(docLen)) // SCI_SETTARGETEND
                let pos = view.message(
                    UInt32(2197), // SCI_SEARCHINTARGET
                    wParam: UInt(needleByteCount),
                    lParam: Int(bitPattern: cStr)
                )
                if pos < 0 { break }
                let mStart = view.message(UInt32(2191)) // SCI_GETTARGETSTART
                let mEnd = view.message(UInt32(2193)) // SCI_GETTARGETEND
                let mLen = max(1, mEnd - mStart)
                view.message(UInt32(2504), wParam: UInt(mStart), lParam: mLen) // SCI_INDICATORFILLRANGE
                targetStart = max(targetStart + 1, mEnd)
            }
        }
    }

    // MARK: - Find Execution

    struct SearchMatchOptions {
        var matchCase: Bool
        var wholeWord: Bool
        var backwards: Bool
        var wrap: Bool
    }

    func handleFind(notif: Notification, backwards: Bool) {
        guard let view = scintillaView else { return }
        var query = notif.userInfo?["query"] as? String ?? ""
        if query.isEmpty {
            query = parent.documentManager?.searchQuery ?? ""
        }
        guard !query.isEmpty else { return }

        let matchCase = notif.userInfo?["matchCase"] as? Bool
            ?? parent.documentManager?.isMatchCase ?? false
        let wholeWord = notif.userInfo?["wholeWord"] as? Bool
            ?? parent.documentManager?.isWholeWord ?? false
        let isRegex = notif.userInfo?["isRegex"] as? Bool
            ?? parent.documentManager?.isRegex ?? false
        let wrap = notif.userInfo?["wrap"] as? Bool
            ?? parent.documentManager?.isWrapAround ?? true

        if isRegex {
            let options = SearchMatchOptions(
                matchCase: matchCase,
                wholeWord: wholeWord,
                backwards: backwards,
                wrap: wrap
            )
            executeRegexFind(view: view, query: query, options: options)
        } else {
            let found = view.findAndHighlightText(
                query,
                matchCase: matchCase,
                wholeWord: wholeWord,
                scrollTo: true,
                wrap: wrap,
                backwards: backwards
            )
            if found {
                notifySearchFound(view: view)
                highlightOccurrences(of: query, matchCase: matchCase)
            } else {
                notifySearchStatus("Not found")
            }
        }
    }

    private func executeRegexFind(
        view: ScintillaView,
        query: String,
        options: SearchMatchOptions
    ) {
        var flags: UInt = 0x00200000 // SCFIND_REGEXP
        if options.matchCase { flags |= 0x4 } // SCFIND_MATCHCASE
        if options.wholeWord { flags |= 0x2 } // SCFIND_WHOLEWORD

        _ = view.message(UInt32(2366)) // SCI_SEARCHANCHOR
        let msg = options.backwards ? UInt32(2368) : UInt32(2367) // SCI_SEARCHPREV : SCI_SEARCHNEXT
        var res = query.withCString { cStr in
            view.message(msg, wParam: flags, lParam: Int(bitPattern: cStr))
        }

        if res < 0 && options.wrap {
            let docLen = view.message(UInt32(2183))
            if options.backwards {
                _ = view.message(UInt32(2142), wParam: UInt(docLen)) // SCI_SETSELECTIONSTART
                _ = view.message(UInt32(2144), wParam: UInt(docLen)) // SCI_SETSELECTIONEND
            } else {
                _ = view.message(UInt32(2142), wParam: 0)
                _ = view.message(UInt32(2144), wParam: 0)
            }
            _ = view.message(UInt32(2366)) // SCI_SEARCHANCHOR
            res = query.withCString { cStr in
                view.message(msg, wParam: flags, lParam: Int(bitPattern: cStr))
            }
        }

        if res >= 0 {
            _ = view.message(UInt32(2169)) // SCI_SCROLLCARET
            notifySearchFound(view: view)
            highlightOccurrences(of: query, matchCase: options.matchCase)
        } else {
            notifySearchStatus("Not found")
        }
    }

    // MARK: - Replace Execution

    func handleReplaceNext(notif: Notification) {
        guard let view = scintillaView else { return }
        var query = notif.userInfo?["query"] as? String ?? ""
        var replace = notif.userInfo?["replace"] as? String ?? ""
        if query.isEmpty {
            query = parent.documentManager?.searchQuery ?? ""
            replace = parent.documentManager?.replaceQuery ?? ""
        }
        guard !query.isEmpty else { return }

        let matchCase = notif.userInfo?["matchCase"] as? Bool
            ?? parent.documentManager?.isMatchCase ?? false
        let wholeWord = notif.userInfo?["wholeWord"] as? Bool
            ?? parent.documentManager?.isWholeWord ?? false
        let isRegex = notif.userInfo?["isRegex"] as? Bool
            ?? parent.documentManager?.isRegex ?? false

        // Check whether the active selection currently matches the find query
        let selStart = view.message(UInt32(2143)) // SCI_GETSELECTIONSTART
        let selEnd = view.message(UInt32(2145)) // SCI_GETSELECTIONEND
        var selectionMatches = false

        if selEnd > selStart, let fullText = view.string() {
            let utf8 = fullText.utf8
            let startIdx = utf8.index(
                utf8.startIndex,
                offsetBy: selStart,
                limitedBy: utf8.endIndex
            ) ?? utf8.startIndex
            let endIdx = utf8.index(
                utf8.startIndex,
                offsetBy: selEnd,
                limitedBy: utf8.endIndex
            ) ?? utf8.endIndex
            if let selected = String(utf8[startIdx..<endIdx]) {
                if isRegex {
                    var options: NSRegularExpression.Options = []
                    if !matchCase { options.insert(.caseInsensitive) }
                    let pattern = wholeWord ? "^\\b(?:\(query))\\b$" : "^\(query)$"
                    if let rx = try? NSRegularExpression(pattern: pattern, options: options) {
                        let range = NSRange(selected.startIndex..<selected.endIndex, in: selected)
                        selectionMatches = rx.numberOfMatches(in: selected, options: [], range: range) > 0
                    }
                } else if matchCase {
                    selectionMatches = (selected == query)
                } else {
                    selectionMatches = (selected.localizedCaseInsensitiveCompare(query) == .orderedSame)
                }
            }
        }

        if selectionMatches {
            // Replace selection atomically
            replace.withCString { cRepl in
                _ = view.message(UInt32(2170), wParam: 0, lParam: Int(bitPattern: cRepl))
            }
            notifySearchStatus("Replaced 1 match")
            // Automatically find next match for smooth continuous replacement
            handleFind(notif: notif, backwards: false)
        } else {
            // First locate next occurrence
            handleFind(notif: notif, backwards: false)
        }
    }

    func handleReplaceAll(notif: Notification) {
        guard let view = scintillaView else { return }
        var query = notif.userInfo?["query"] as? String ?? ""
        var replace = notif.userInfo?["replace"] as? String ?? ""
        if query.isEmpty {
            query = parent.documentManager?.searchQuery ?? ""
            replace = parent.documentManager?.replaceQuery ?? ""
        }
        guard !query.isEmpty else { return }

        let matchCase = notif.userInfo?["matchCase"] as? Bool
            ?? parent.documentManager?.isMatchCase ?? false
        let wholeWord = notif.userInfo?["wholeWord"] as? Bool
            ?? parent.documentManager?.isWholeWord ?? false
        let isRegex = notif.userInfo?["isRegex"] as? Bool
            ?? parent.documentManager?.isRegex ?? false

        if isRegex {
            guard let fullText = view.string() else { return }
            let pattern = wholeWord ? "\\b(?:\(query))\\b" : query
            var options: NSRegularExpression.Options = []
            if !matchCase { options.insert(.caseInsensitive) }

            guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
                notifySearchStatus("Invalid regex pattern")
                return
            }
            let fullRange = NSRange(fullText.startIndex..<fullText.endIndex, in: fullText)
            let count = regex.numberOfMatches(in: fullText, options: [], range: fullRange)
            if count > 0 {
                let replaced = regex.stringByReplacingMatches(
                    in: fullText,
                    options: [],
                    range: fullRange,
                    withTemplate: replace
                )
                view.message(UInt32(2078)) // SCI_BEGINUNDOACTION
                view.setString(replaced)
                view.message(UInt32(2079)) // SCI_ENDUNDOACTION
                notifySearchStatus("Replaced \(count) occurrence(s)")
            } else {
                notifySearchStatus("No match to replace")
            }
        } else {
            let count = view.findAndReplaceText(
                query,
                byText: replace,
                matchCase: matchCase,
                wholeWord: wholeWord,
                doAll: true
            )
            if count > 0 {
                notifySearchStatus("Replaced \(count) occurrence(s)")
            } else {
                notifySearchStatus("No match to replace")
            }
        }
        clearHighlights()
    }

    func handleCount(notif: Notification) {
        guard let view = scintillaView else { return }
        var query = notif.userInfo?["query"] as? String ?? ""
        if query.isEmpty {
            query = parent.documentManager?.searchQuery ?? ""
        }
        guard !query.isEmpty else { return }

        let matchCase = notif.userInfo?["matchCase"] as? Bool
            ?? parent.documentManager?.isMatchCase ?? false
        let wholeWord = notif.userInfo?["wholeWord"] as? Bool
            ?? parent.documentManager?.isWholeWord ?? false
        let isRegex = notif.userInfo?["isRegex"] as? Bool
            ?? parent.documentManager?.isRegex ?? false

        let fullText = view.string() ?? ""
        let count = countMatches(
            in: fullText,
            query: query,
            matchCase: matchCase,
            wholeWord: wholeWord,
            isRegex: isRegex
        )

        // Highlight counted matches visually for the user
        if !isRegex {
            highlightOccurrences(of: query, matchCase: matchCase)
        }

        notifySearchStatus("Count: \(count) occurrence(s) found")
    }

    private func countMatches(
        in text: String,
        query: String,
        matchCase: Bool,
        wholeWord: Bool,
        isRegex: Bool
    ) -> Int {
        guard !text.isEmpty, !query.isEmpty else { return 0 }
        let pattern: String
        if isRegex {
            pattern = wholeWord ? "\\b(?:\(query))\\b" : query
        } else {
            let escaped = NSRegularExpression.escapedPattern(for: query)
            pattern = wholeWord ? "\\b\(escaped)\\b" : escaped
        }

        var options: NSRegularExpression.Options = []
        if !matchCase {
            options.insert(.caseInsensitive)
        }

        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return 0
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.numberOfMatches(in: text, options: [], range: range)
    }

    private func handleUseSelectionForFind() {
        guard let view = scintillaView else { return }
        let start = view.message(UInt32(2143))
        let end = view.message(UInt32(2145))
        guard end > start else { return }

        let fullText = view.string() ?? ""
        let utf8 = fullText.utf8
        let startIdx = utf8.index(
            utf8.startIndex,
            offsetBy: Int(start),
            limitedBy: utf8.endIndex
        ) ?? utf8.startIndex
        let endIdx = utf8.index(
            utf8.startIndex,
            offsetBy: Int(end),
            limitedBy: utf8.endIndex
        ) ?? utf8.endIndex

        if let selected = String(utf8[startIdx..<endIdx]) {
            parent.documentManager?.searchQuery = selected
            parent.documentManager?.isFindReplaceBarVisible = true
            NotificationCenter.default.post(
                name: .notepadUseSelectionForFind,
                object: nil,
                userInfo: ["query": selected]
            )
        }
    }

    private func notifySearchFound(view: ScintillaView) {
        let currentPos = view.message(UInt32(SCI_GETCURRENTPOS))
        let line = view.message(UInt32(SCI_LINEFROMPOSITION), wParam: UInt(currentPos))
        notifySearchStatus("Found at line \(line + 1)")
    }

    private func notifySearchStatus(_ msg: String) {
        NotificationCenter.default.post(
            name: .notepadSearchStatusUpdate,
            object: nil,
            userInfo: ["status": msg]
        )
    }
}
