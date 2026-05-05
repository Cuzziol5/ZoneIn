import SwiftUI

// MARK: - EMPTY STATE VIEW

// EmptyStateView is a reusable view used when a screen has no content yet.
// Example: if the user has no favorite quotes, this view can show a message like
// "No favorites yet" with an icon and subtitle.
struct EmptyStateView: View {

    // MARK: - PROPERTIES

    // The SF Symbol icon that will appear at the top of the empty state card.
    let iconName: String

    // The main title text.
    let title: String

    // The smaller explanation text under the title.
    let subtitle: String

    // The selected app theme.
    // This lets the empty state match the rest of the app's design.
    let selectedAppearance: ThemeOption


    // MARK: - THEME

    // Gets the correct colors for the selected theme.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }


    // MARK: - BODY

    var body: some View {
        VStack(spacing: 16) {

            // Displays the icon.
            Image(systemName: iconName)
                .foregroundColor(currentTheme.accent)
                .font(.system(size: 42))

            // Displays the main title.
            Text(title)
                .foregroundColor(currentTheme.primaryText)
                .font(.title3)
                .fontWeight(.semibold)

            // Displays the smaller subtitle/explanation.
            Text(subtitle)
                .foregroundColor(currentTheme.secondaryText)
                .font(.body)
                .multilineTextAlignment(.center)
        }

        // Adds space inside the card.
        .padding(28)

        // Makes the card stretch across the screen.
        .frame(maxWidth: .infinity)

        // Gives the card a theme-based background color.
        .background(currentTheme.cardBackground)

        // Rounds the corners of the card.
        .cornerRadius(24)
    }
}
