import SwiftUI

// MARK: - THEME
// This file controls all of the color themes used in ZoneIn.
// Instead of hard-coding colors on every screen, the app pulls colors from here.

// ThemeOption stores the different theme choices the user can select.
// Raw String values are the names that appear in the app.
enum ThemeOption: String, CaseIterable, Codable {
    
    // Default dark theme
    case original = "Classic"
    
    // Light theme
    case white = "White"
    
    // Dark blue focus theme
    case midnightBlue = "Midnight Blue"
    
    // Red and black intense focus theme
    case infernoFocus = "Inferno Focus"
    
    // Green and dark nature-inspired focus theme
    case forestFocus = "Forest Focus"
}

// AppTheme stores all of the colors needed for one theme.
// Each screen can use these same color names to stay consistent.
struct AppTheme {
    
    // Main background color of the screen
    let background: Color
    
    // Secondary background color used for sections or grouped areas
    let secondaryBackground: Color
    
    // Card background color used for buttons, cards, and containers
    let cardBackground: Color
    
    // Main text color
    let primaryText: Color
    
    // Secondary text color used for subtitles or less important text
    let secondaryText: Color
    
    // Accent color used for highlights, buttons, and important UI elements
    let accent: Color
    
    // Icon color
    let icon: Color
}

// This function returns the correct set of colors based on the selected theme.
// When the user changes themes, the app calls this function to update the UI colors.
func themeColors(for theme: ThemeOption) -> AppTheme {
    
    // Switch checks which theme is currently selected.
    switch theme {
        
    case .original:
        // Classic theme: black background with blue accent
        return AppTheme(
            background: .black,
            secondaryBackground: Color.white.opacity(0.05),
            cardBackground: Color.white.opacity(0.08),
            primaryText: .white,
            secondaryText: .gray,
            accent: .blue,
            icon: .white
        )

    case .white:
        // White theme: light background with black text
        return AppTheme(
            background: .white,
            secondaryBackground: Color.black.opacity(0.04),
            cardBackground: Color.black.opacity(0.06),
            primaryText: .black,
            secondaryText: .gray,
            accent: .blue,
            icon: .black
        )

    case .midnightBlue:
        // Midnight Blue theme: dark blue background with bright blue accent
        return AppTheme(
            background: Color(red: 0.03, green: 0.07, blue: 0.16),
            secondaryBackground: Color.white.opacity(0.06),
            cardBackground: Color.white.opacity(0.08),
            primaryText: .white,
            secondaryText: Color(red: 0.70, green: 0.76, blue: 0.87),
            accent: Color(red: 0.25, green: 0.50, blue: 1.00),
            icon: .white
        )

    case .infernoFocus:
        // Inferno Focus theme: dark red and black theme for an intense look
        return AppTheme(
            background: Color(red: 0.04, green: 0.00, blue: 0.00),
            secondaryBackground: Color.red.opacity(0.10),
            cardBackground: Color.white.opacity(0.08),
            primaryText: .white,
            secondaryText: Color.white.opacity(0.70),
            accent: Color(red: 0.95, green: 0.08, blue: 0.12),
            icon: .white
        )

    case .forestFocus:
        // Forest Focus theme: dark green theme with a bright green accent
        return AppTheme(
            background: Color(red: 0.02, green: 0.08, blue: 0.05),
            secondaryBackground: Color.green.opacity(0.10),
            cardBackground: Color.white.opacity(0.08),
            primaryText: .white,
            secondaryText: Color.white.opacity(0.72),
            accent: Color(red: 0.16, green: 0.78, blue: 0.38),
            icon: .white
        )
    }
}
