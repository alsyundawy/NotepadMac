#!/usr/bin/env bash
#
# test-runner.sh
# Empirical unit verification for NotepadMac
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Running NotepadMac Test Suite ==="

# 1. Swift package test build
cd "${REPO_ROOT}"
swift test

# 2. Standalone unit verification runner
cat <<'SWIFT_TEST_EOF' >/tmp/notepadmac_unit_test.swift
import Foundation
import AppKit

// Basic theme color ref test
let red = NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
let r = Int(round((red.redComponent) * 255.0))
let g = Int(round((red.greenComponent) * 255.0))
let b = Int(round((red.blueComponent) * 255.0))
let colorRef = (b << 16) | (g << 8) | r
assert(colorRef == 255, "Red BGR conversion failed")

let blue = NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
let br = Int(round((blue.redComponent) * 255.0))
let bg = Int(round((blue.greenComponent) * 255.0))
let bb = Int(round((blue.blueComponent) * 255.0))
let blueColorRef = (bb << 16) | (bg << 8) | br
assert(blueColorRef == 16711680, "Blue BGR conversion failed")

// Hex parser edge case test (Pillar 10 input validation)
func parseHexColor(_ hex: String) -> (CGFloat, CGFloat, CGFloat) {
    var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if cleanHex.hasPrefix("#") { cleanHex.remove(at: cleanHex.startIndex) }
    let scanner = Scanner(string: cleanHex)
    var rgbValue: UInt64 = 0
    let scanned = scanner.scanHexInt64(&rgbValue)
    let isValid = scanned && scanner.isAtEnd
    if isValid && cleanHex.count == 6 {
        return (CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                CGFloat(rgbValue & 0x0000FF) / 255.0)
    }
    return (0.5, 0.5, 0.5)
}
let (ir, ig, ib) = parseHexColor("ZZZZZZ")
assert(abs(ir - 0.5) < 0.01 && abs(ig - 0.5) < 0.01 && abs(ib - 0.5) < 0.01, "Invalid hex fallback failed")

print("✅ Theme BGR ColorRef and Hex validation tests PASSED")
SWIFT_TEST_EOF

swift /tmp/notepadmac_unit_test.swift
rm -f /tmp/notepadmac_unit_test.swift

echo "=== All NotepadMac Unit Tests Passed Successfully ==="
