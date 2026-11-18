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
import CLua

public protocol EditorActionDelegate: AnyObject {
    func editorGetText() -> String
    func editorSetText(_ text: String)
    func editorGetSelection() -> String
    func editorReplaceSelection(_ text: String)
    func editorGetLineCount() -> Int
    func editorGetCurrentLine() -> Int
    func editorInsertText(at position: Int, text: String)
    func editorClear()
    func editorZoomIn()
    func editorZoomOut()
}

public struct LuaExecutionResult {
    public let success: Bool
    public let output: String
    public let error: String?
}

public final class LuaEngine {
    private var luaStatePtr: OpaquePointer?
    private weak var currentDelegate: EditorActionDelegate?
    private var outputBuffer: [String] = []

    public init() {
        initLuaState()
    }

    deinit {
        if let state = luaStatePtr {
            lua_close(state)
        }
    }

    private func initLuaState() {
        luaStatePtr = luaL_newstate()
        guard let state = luaStatePtr else { return }
        lua_open_all_libs(state)
        setupPrintRedirection()
        setupEditorTable()
    }

    public func reset() {
        if let state = luaStatePtr {
            lua_close(state)
        }
        outputBuffer.removeAll()
        initLuaState()
    }

    public func execute(
        script: String,
        delegate: EditorActionDelegate?
    ) -> LuaExecutionResult {
        outputBuffer.removeAll()
        self.currentDelegate = delegate

        guard let state = luaStatePtr else {
            return LuaExecutionResult(
                success: false,
                output: "",
                error: "Lua state is not initialized"
            )
        }

        let enginePtr = Unmanaged.passUnretained(self).toOpaque()
        lua_pushlightuserdata(state, enginePtr)
        lua_setfield(state, lua_registry_index(), "notepad_engine_instance")

        let status = script.withCString { cStr in
            lua_do_string(state, cStr)
        }
        let output = outputBuffer.joined(separator: "\n")

        if status != 0 {
            let errorMsg: String
            if let errStr = lua_to_string(state, -1) {
                errorMsg = String(cString: errStr)
                lua_settop(state, -2)
            } else {
                errorMsg = "Unknown Lua runtime error"
            }
            return LuaExecutionResult(success: false, output: output, error: errorMsg)
        }

        return LuaExecutionResult(success: true, output: output, error: nil)
    }

    // MARK: - Internal Callback Helpers

    fileprivate func appendOutput(_ text: String) {
        outputBuffer.append(text)
    }

    fileprivate var activeDelegate: EditorActionDelegate? {
        return currentDelegate
    }

    // MARK: - Setup Print & Editor API

    private func setupPrintRedirection() {
        guard let state = luaStatePtr else { return }

        let printFunc: @convention(c) (OpaquePointer?) -> Int32 = { statePtr in
            guard let statePtr = statePtr else { return 0 }
            lua_getfield(statePtr, lua_registry_index(), "notepad_engine_instance")
            guard let rawPtr = lua_touserdata(statePtr, -1) else {
                lua_settop(statePtr, -2)
                return 0
            }
            lua_settop(statePtr, -2)

            let engine = Unmanaged<LuaEngine>.fromOpaque(rawPtr).takeUnretainedValue()
            let nArgs = lua_gettop(statePtr)
            var parts: [String] = []

            for paramIdx in 1...nArgs {
                if let str = lua_to_string(statePtr, paramIdx) {
                    parts.append(String(cString: str))
                } else if lua_is_boolean(statePtr, paramIdx) != 0 {
                    parts.append(lua_toboolean(statePtr, paramIdx) != 0 ? "true" : "false")
                } else if lua_is_nil(statePtr, paramIdx) != 0 {
                    parts.append("nil")
                } else {
                    parts.append("<value>")
                }
            }

            engine.appendOutput(parts.joined(separator: "\t"))
            return 0
        }

        lua_pushcclosure(state, printFunc, 0)
        lua_setglobal(state, "print")
    }

    private func setupEditorTable() {
        guard let state = luaStatePtr else { return }

        lua_createtable(state, 0, 0)

        let methods = [
            "getText", "setText", "getSelection", "replaceSelection",
            "getLineCount", "getCurrentLine", "insertText", "clear",
            "zoomIn", "zoomOut"
        ]

        for method in methods {
            registerEditorMethod(name: method)
        }

        lua_setglobal(state, "editor")
    }

    private func registerEditorMethod(name: String) {
        guard let state = luaStatePtr else { return }

        let cCallback: @convention(c) (OpaquePointer?) -> Int32 = { statePtr in
            guard let statePtr = statePtr else { return 0 }
            lua_getfield(statePtr, lua_registry_index(), "notepad_engine_instance")
            guard let rawPtr = lua_touserdata(statePtr, -1) else {
                lua_settop(statePtr, -2)
                return 0
            }
            lua_settop(statePtr, -2)

            let engine = Unmanaged<LuaEngine>.fromOpaque(rawPtr).takeUnretainedValue()
            let delegate = engine.activeDelegate

            guard let nameC = lua_to_string(statePtr, lua_upvalue_index(1)) else { return 0 }
            let methodName = String(cString: nameC)

            return LuaEngine.dispatchEditorMethod(
                name: methodName,
                state: statePtr,
                delegate: delegate
            )
        }

        lua_pushstring(state, name)
        lua_pushcclosure(state, cCallback, 1)
        lua_setfield(state, -2, name)
    }

    private static func dispatchEditorMethod(
        name: String,
        state: OpaquePointer,
        delegate: EditorActionDelegate?
    ) -> Int32 {
        if let result = dispatchTextMethod(name: name, state: state, delegate: delegate) {
            return result
        }
        return dispatchControlMethod(name: name, state: state, delegate: delegate)
    }

    private static func dispatchTextMethod(
        name: String,
        state: OpaquePointer,
        delegate: EditorActionDelegate?
    ) -> Int32? {
        switch name {
        case "getText":
            let text = delegate?.editorGetText() ?? ""
            lua_pushstring(state, text)
            return 1
        case "setText":
            if let str = lua_to_string(state, 1) {
                delegate?.editorSetText(String(cString: str))
            }
            return 0
        case "getSelection":
            let sel = delegate?.editorGetSelection() ?? ""
            lua_pushstring(state, sel)
            return 1
        case "replaceSelection":
            if let str = lua_to_string(state, 1) {
                delegate?.editorReplaceSelection(String(cString: str))
            }
            return 0
        default:
            return nil
        }
    }

    private static func dispatchControlMethod(
        name: String,
        state: OpaquePointer,
        delegate: EditorActionDelegate?
    ) -> Int32 {
        switch name {
        case "getLineCount":
            let count = delegate?.editorGetLineCount() ?? 0
            lua_pushinteger(state, lua_Integer(count))
            return 1
        case "getCurrentLine":
            let line = delegate?.editorGetCurrentLine() ?? 1
            lua_pushinteger(state, lua_Integer(line))
            return 1
        case "insertText":
            let pos = Int(lua_to_integer(state, 1))
            if let str = lua_to_string(state, 2) {
                delegate?.editorInsertText(at: pos, text: String(cString: str))
            }
            return 0
        case "clear":
            delegate?.editorClear()
            return 0
        case "zoomIn":
            delegate?.editorZoomIn()
            return 0
        case "zoomOut":
            delegate?.editorZoomOut()
            return 0
        default:
            return 0
        }
    }
}
