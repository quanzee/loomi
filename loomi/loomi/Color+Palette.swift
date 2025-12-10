import SwiftUI

extension Color {
    /// Initialize a Color from a 24-bit hex value like 0xRRGGBB and optional alpha.
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue:  Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }

    // App color palette
    static let paletteBackground = Color(hex: 0x282828)
    static let paletteText       = Color(hex: 0xD9D9D9)
    static let paletteBigBlock   = Color(hex: 0xCBFF8C)
    static let paletteValue      = Color(hex: 0xE4E6C3)
}
