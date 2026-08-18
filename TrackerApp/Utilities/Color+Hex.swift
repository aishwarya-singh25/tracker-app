//
//  Color+Hex.swift
//  TrackerApp
//

import SwiftUI

extension Color {
    /// Creates a Color from a "#RRGGBB" hex string. Falls back to gray if malformed.
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard hexString.count == 6, Scanner(string: hexString).scanHexInt64(&rgb) else {
            self = .gray
            return
        }

        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
