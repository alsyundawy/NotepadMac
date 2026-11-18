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

import SwiftUI
import AppKit

public struct ModalCloseButton: View {
    private let action: () -> Void
    @State private var isHovered: Bool = false

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        ZStack {
            // Hidden shortcut receiver for Esc key (cancelAction) without visual footprint or focus ring
            Button(action: action) {
                EmptyView()
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut(.cancelAction)
            .frame(width: 0, height: 0)
            .opacity(0)
            .focusable(false)

            // Pure non-focusable visual close icon with tap gesture & circular hover effect
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isHovered ? Color(NSColor.labelColor) : Color(NSColor.secondaryLabelColor))
                .frame(width: 22, height: 22)
                .background(
                    Circle()
                        .fill(isHovered ? Color(NSColor.quaternaryLabelColor) : Color.clear)
                )
                .contentShape(Circle())
                .onHover { hovering in
                    isHovered = hovering
                }
                .onTapGesture {
                    action()
                }
        }
        .help(loc("close"))
    }
}
