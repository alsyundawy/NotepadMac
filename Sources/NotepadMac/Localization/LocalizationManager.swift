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
import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case indonesian = "id"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .english:
            return "English"
        case .indonesian:
            return "Bahasa Indonesia"
        }
    }

    public var flag: String {
        switch self {
        case .english:
            return "🇺🇸"
        case .indonesian:
            return "🇮🇩"
        }
    }
}

public final class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()

    private let userDefaultsKey = "notepad_app_language"

    @Published public var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: userDefaultsKey)
        }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: userDefaultsKey),
           let lang = AppLanguage(rawValue: saved) {
            self.currentLanguage = lang
        } else {
            // Default to Indonesian if system language starts with "id", else English
            let preferred = Locale.preferredLanguages.first ?? "en"
            self.currentLanguage = preferred.hasPrefix("id") ? .indonesian : .english
        }
    }

    public func localized(_ key: String) -> String {
        if let translation = translations[currentLanguage]?[key] {
            return translation
        }
        if let fallback = translations[.english]?[key] {
            return fallback
        }
        return key
    }

    // Comprehensive Dictionary for UI, Menus, Dialogs, Toolbar, Tabs, Preferences, and Tools
    private let translations: [AppLanguage: [String: String]] = [
        .english: [
            // App & General
            "app_name": "NotepadMac",
            "ready": "Ready",
            "modified": "Modified",
            "saved": "Saved",
            "unsaved_changes": "Unsaved changes",
            "done": "Done",
            "cancel": "Cancel",
            "ok": "OK",
            "apply": "Apply",
            "copy": "Copy",
            "copied": "Copied to clipboard!",
            "close": "Close",
            "preferences": "Preferences",
            "about": "About NotepadMac",
            "check_updates": "Check for Updates...",
            "keyboard_shortcuts": "Keyboard Shortcuts",
            "quit": "Quit NotepadMac",
            "quit_tooltip": "Quit NotepadMac (⌘Q)",

            // Tabs & Files
            "new_tab": "New Tab",
            "new_document": "New Document",
            "open_file": "Open File...",
            "save": "Save",
            "save_as": "Save As...",
            "save_all": "Save All",
            "save_changes_title": "Do you want to save the changes made to the document “%@”?",
            "save_changes_message": "Your changes will be lost if you don't save them.",
            "dont_save": "Don't Save",
            "close_tab": "Close Tab",
            "close_other_tabs": "Close Other Tabs",
            "close_tabs_to_right": "Close Tabs to the Right",
            "close_all_tabs": "Close All Tabs",
            "copy_full_path": "Copy Full Path",
            "reveal_in_finder": "Reveal in Finder",
            "color_tag": "Color Tag",
            "none": "None",
            "page_setup": "Page Setup...",
            "print": "Print...",

            // Edit & History
            "undo": "Undo",
            "redo": "Redo",
            "cut": "Cut",
            "copy_action": "Copy",
            "paste": "Paste",
            "select_all": "Select All",
            "duplicate_line": "Duplicate Line",
            "delete_line": "Delete Line",
            "date_time": "Time/Date",
            "convert_case": "Convert Case",
            "uppercase": "UPPERCASE",
            "lowercase": "lowercase",
            "capitalize": "Capitalize",
            "invert_case": "Invert Case",
            "sentence_case": "Sentence case",

            // Search & Find
            "find": "Find",
            "find_dots": "Find...",
            "replace": "Replace",
            "replace_dots": "Replace...",
            "mark": "Mark",
            "find_bar": "Toggle Find Bar",
            "find_next": "Find Next",
            "find_prev": "Find Previous",
            "replace_next": "Replace Next",
            "replace_all": "Replace All",
            "find_replace_hub": "Find & Replace Hub",
            "find_what": "Find what:",
            "replace_with": "Replace with:",
            "mark_what": "Mark what:",
            "mark_all": "Mark All",
            "clear_all_marks": "Clear All Marks",
            "copy_marked_text": "Copy Marked Text",
            "bookmark_line": "Bookmark Line",
            "purge_for_each_search": "Purge for each search",
            "search_options": "Search Options",
            "direction": "Direction",
            "down": "Down",
            "up": "Up",
            "ready_to_search": "Ready to search",
            "count_matches": "Count Matches",
            "match_case": "Match Case",
            "whole_word": "Whole Word",
            "regex": "Regular Expression",
            "wrap_around": "Wrap Around",
            "search_direction_up": "Search Backward / Up",
            "search_field_placeholder": "Text to find...",
            "replace_field_placeholder": "Replace with...",
            "no_matches_found": "No matches found",
            "use_selection_for_find": "Use Selection for Find",
            "go_to_line": "Go to Line...",
            "line_number": "Line number:",

            // View & Formatting
            "view": "View",
            "line_numbers": "Toggle Line Numbers",
            "code_folding": "Toggle Code Folding",
            "white_space": "Toggle White Space & EOL",
            "indent_guides": "Toggle Indentation Guides",
            "word_wrap": "Word Wrap",
            "zoom_in": "Zoom In",
            "zoom_out": "Zoom Out",
            "reset_zoom": "Reset Zoom (100%)",

            // Tools Menu & Hub
            "tools": "Tools",
            "tools_hub": "Tools Hub (Hash, MIME, Crypto, DevTools)...",
            "hash_tools": "Hash & Checksums",
            "mime_tools": "MIME & Encoding",
            "converter": "Converter",
            "encryption": "Encryption & Decryption",
            "developer_tools": "Developer Tools",
            "lua_console": "Lua Scripting Console",

            // Specific Tools Actions
            "generate_hash": "Generate Hash Digest",
            "file_checksum": "File Checksum",
            "text_hash": "Text Hash",
            "choose_file": "Choose File...",
            "compare_file": "Compare with File...",
            "file_size": "File Size",
            "file_path": "File Path",
            "html_minify": "Minify HTML",
            "html_format": "Format HTML",
            "css_minify": "Minify CSS",
            "css_format": "Format CSS",
            "js_minify": "Minify JS",
            "js_format": "Format JS",
            "html_encrypt": "Encrypt HTML",
            "html_decrypt": "Decrypt HTML",
            "hash_algorithm": "Algorithm",
            "base64_encode": "Base64 Encode",
            "base64_decode": "Base64 Decode",
            "url_encode": "URL Encode (RFC 3986)",
            "url_decode": "URL Decode",
            "html_entity_encode": "HTML Entity Encode",
            "html_entity_decode": "HTML Entity Decode",
            "quoted_printable_encode": "Quoted-Printable Encode",
            "quoted_printable_decode": "Quoted-Printable Decode",
            "ascii_to_hex": "ASCII to HEX",
            "hex_to_ascii": "HEX to ASCII",
            "number_converter": "Number Base Converter",
            "encrypt_aes": "AES-256 Encrypt",
            "decrypt_aes": "AES-256 Decrypt",
            "passphrase": "Secret Passphrase",
            "format_json": "Format / Prettify JSON",
            "minify_json": "Minify JSON",
            "format_xml": "Format XML",
            "minify_xml": "Minify XML",
            "jwt_decoder": "Decode JWT Token",
            "generate_uuid": "Generate UUID v4",
            "epoch_converter": "Timestamp / Unix Epoch Converter",
            "apply_to_active_doc": "Apply to Active Document",
            "apply_to_selection": "Replace Selection",

            // Preferences
            "general": "General",
            "themes": "Themes",
            "editor": "General",
            "app_language": "Application Language",
            "language_restart_note": "Language changes apply immediately throughout the application.",
            "editor_font": "Editor Monospaced Font",
            "font_size": "Font Size",
            "tab_size": "Tab Indent Size",
            "insert_spaces": "Indent with spaces instead of tabs",
            "appearance_options": "Editor Appearance & Margins",
            "autocompletion": "Code Auto-Completion",
            "autocompletion_desc": "Show suggestions while typing keywords",

            // Status Bar
            "lines": "lines",
            "line_short": "Ln",
            "col_short": "Col",
            "selected_short": "sel",

            // Update Dialog
            "update_check_title": "Check for Updates",
            "current_version": "Current Version",
            "checking_for_updates": "Checking for updates from GitHub...",
            "up_to_date": "You are using the latest version of NotepadMac!",
            "check_again": "Check Again",
            "visit_releases": "Visit GitHub Releases"
        ],
        .indonesian: [
            // App & General
            "app_name": "NotepadMac",
            "ready": "Siap",
            "modified": "Diubah",
            "saved": "Tersimpan",
            "unsaved_changes": "Perubahan belum disimpan",
            "done": "Selesai",
            "cancel": "Batal",
            "ok": "OK",
            "apply": "Terapkan",
            "copy": "Salin",
            "copied": "Berhasil disalin ke papan klip!",
            "close": "Tutup",
            "preferences": "Preferensi",
            "about": "Tentang NotepadMac",
            "check_updates": "Periksa Pembaruan...",
            "keyboard_shortcuts": "Pintasan Keyboard",
            "quit": "Keluar dari NotepadMac",
            "quit_tooltip": "Keluar dari NotepadMac (⌘Q)",

            // Tabs & Files
            "new_tab": "Tab Baru",
            "new_document": "Dokumen Baru",
            "open_file": "Buka Berkas...",
            "save": "Simpan",
            "save_as": "Simpan Sebagai...",
            "save_all": "Simpan Semua",
            "save_changes_title": "Apakah Anda ingin menyimpan perubahan pada dokumen “%@”?",
            "save_changes_message": "Perubahan Anda akan hilang jika Anda tidak menyimpannya.",
            "dont_save": "Jangan Simpan",
            "close_tab": "Tutup Tab",
            "close_other_tabs": "Tutup Tab Lainnya",
            "close_tabs_to_right": "Tutup Tab di Sebelah Kanan",
            "close_all_tabs": "Tutup Semua Tab",
            "copy_full_path": "Salin Jalur Lengkap",
            "reveal_in_finder": "Tampilkan di Finder",
            "color_tag": "Tanda Warna",
            "none": "Tidak Ada",
            "page_setup": "Tata Letak Halaman...",
            "print": "Cetak...",

            // Edit & History
            "undo": "Urungkan",
            "redo": "Ulangi",
            "cut": "Potong",
            "copy_action": "Salin",
            "paste": "Tempel",
            "select_all": "Pilih Semua",
            "duplicate_line": "Duplikasi Baris",
            "delete_line": "Hapus Baris",
            "date_time": "Waktu/Tanggal",
            "convert_case": "Ubah Huruf Besar/Kecil",
            "uppercase": "HURUF BESAR",
            "lowercase": "huruf kecil",
            "capitalize": "Huruf Awal Kapital",
            "invert_case": "Balik Huruf Besar/Kecil",
            "sentence_case": "Huruf kalimat",

            // Search & Find
            "find": "Cari",
            "find_dots": "Cari...",
            "replace": "Ganti",
            "replace_dots": "Ganti...",
            "mark": "Tandai",
            "find_bar": "Bilah Pencarian",
            "find_next": "Cari Berikutnya",
            "find_prev": "Cari Sebelumnya",
            "replace_next": "Ganti Berikutnya",
            "replace_all": "Ganti Semua",
            "find_replace_hub": "Pusat Cari, Ganti & Tandai",
            "find_what": "Temukan:",
            "replace_with": "Ganti dengan:",
            "mark_what": "Teks ditandai:",
            "mark_all": "Tandai Semua",
            "clear_all_marks": "Hapus Semua Tanda",
            "copy_marked_text": "Salin Teks Ditandai",
            "bookmark_line": "Tandai Baris (Bookmark)",
            "purge_for_each_search": "Bersihkan tiap pencarian",
            "search_options": "Opsi Pencarian",
            "direction": "Arah",
            "down": "Ke Bawah",
            "up": "Ke Atas",
            "ready_to_search": "Siap mencari",
            "count_matches": "Hitung Kecocokan",
            "match_case": "Cocokkan Huruf Besar/Kecil",
            "whole_word": "Hanya Kata Utuh",
            "regex": "Ekspresi Reguler (Regex)",
            "wrap_around": "Ulang dari Awal",
            "search_direction_up": "Cari ke Atas / Mundur",
            "search_field_placeholder": "Teks yang dicari...",
            "replace_field_placeholder": "Ganti dengan...",
            "no_matches_found": "Tidak ada kecocokan ditemukan",
            "use_selection_for_find": "Gunakan Pilihan untuk Pencarian",
            "go_to_line": "Lompat ke Baris...",
            "line_number": "Nomor baris:",

            // View & Formatting
            "view": "Tampilan",
            "line_numbers": "Nomor Baris",
            "code_folding": "Lipatan Kode",
            "white_space": "Spasi & Akhir Baris (EOL)",
            "indent_guides": "Panduan Indentasi",
            "word_wrap": "Lipat Teks (Word Wrap)",
            "zoom_in": "Perbesar",
            "zoom_out": "Perkecil",
            "reset_zoom": "Atur Ulang Zoom (100%)",

            // Tools Menu & Hub
            "tools": "Alat",
            "tools_hub": "Pusat Alat (Hash, MIME, Kripto, DevTools)...",
            "hash_tools": "Hash & Checksum",
            "mime_tools": "Alat MIME & Enkode",
            "converter": "Pengonversi",
            "encryption": "Enkripsi & Dekripsi",
            "developer_tools": "Alat Pengembang",
            "lua_console": "Konsol Skrip Lua",

            // Specific Tools Actions
            "generate_hash": "Buat Ringkasan Hash",
            "file_checksum": "Checksum Berkas",
            "text_hash": "Hash Teks",
            "choose_file": "Pilih Berkas...",
            "compare_file": "Bandingkan Berkas...",
            "file_size": "Ukuran Berkas",
            "file_path": "Jalur Berkas",
            "html_minify": "Minifikasi HTML",
            "html_format": "Format HTML",
            "css_minify": "Minifikasi CSS",
            "css_format": "Format CSS",
            "js_minify": "Minifikasi JS",
            "js_format": "Format JS",
            "html_encrypt": "Enkripsi HTML",
            "html_decrypt": "Dekripsi HTML",
            "hash_algorithm": "Algoritma",
            "base64_encode": "Enkode Base64",
            "base64_decode": "Dekode Base64",
            "url_encode": "Enkode URL (RFC 3986)",
            "url_decode": "Dekode URL",
            "html_entity_encode": "Enkode Entitas HTML",
            "html_entity_decode": "Dekode Entitas HTML",
            "quoted_printable_encode": "Enkode Quoted-Printable",
            "quoted_printable_decode": "Dekode Quoted-Printable",
            "ascii_to_hex": "ASCII ke HEX",
            "hex_to_ascii": "HEX ke ASCII",
            "number_converter": "Konversi Basis Bilangan",
            "encrypt_aes": "Enkripsi AES-256",
            "decrypt_aes": "Dekripsi AES-256",
            "passphrase": "Kata Sandi Rahasia",
            "format_json": "Format / Percantik JSON",
            "minify_json": "Minimalkan JSON",
            "format_xml": "Format XML",
            "minify_xml": "Minimalkan XML",
            "jwt_decoder": "Dekode Token JWT",
            "generate_uuid": "Buat UUID v4",
            "epoch_converter": "Konversi Waktu / Unix Epoch",
            "apply_to_active_doc": "Terapkan ke Dokumen Aktif",
            "apply_to_selection": "Gantikan Pilihan Teks",

            // Preferences
            "general": "Umum",
            "themes": "Tema",
            "editor": "Umum",
            "app_language": "Bahasa Aplikasi",
            "language_restart_note": "Perubahan bahasa langsung berlaku di seluruh aplikasi secara otomatis.",
            "editor_font": "Font Monospace Editor",
            "font_size": "Ukuran Font",
            "tab_size": "Ukuran Indentasi Tab",
            "insert_spaces": "Gunakan spasi daripada karakter tab",
            "appearance_options": "Tampilan & Margin Editor",
            "autocompletion": "Penyelesaian Kode Otomatis",
            "autocompletion_desc": "Tampilkan saran kata saat mengetik kata kunci",

            // Status Bar
            "lines": "baris",
            "line_short": "Brs",
            "col_short": "Kol",
            "selected_short": "terpilih",

            // Update Dialog
            "update_check_title": "Periksa Pembaruan",
            "current_version": "Versi Saat Ini",
            "checking_for_updates": "Memeriksa pembaruan dari GitHub...",
            "up_to_date": "Anda menggunakan versi NotepadMac paling baru!",
            "check_again": "Periksa Lagi",
            "visit_releases": "Kunjungi Rilis GitHub"
        ]
    ]
}

// Global shorthand for localization
public func loc(_ key: String) -> String {
    LocalizationManager.shared.localized(key)
}
