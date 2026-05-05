import SwiftUI

// MARK: - MENU

struct MenuView: View {
    @Binding var favoriteQuotes: [FavoriteQuote]
    @Binding var focusHistory: [FocusSession]
    @Binding var selectedAppearance: ThemeOption

    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        ZStack {
            currentTheme.background.ignoresSafeArea()

            VStack(spacing: 28) {
                Text("Menu")
                    .foregroundColor(currentTheme.primaryText)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)

                VStack(spacing: 18) {
                    NavigationLink {
                        FavoritesView(
                            favoriteQuotes: $favoriteQuotes,
                            selectedAppearance: $selectedAppearance
                        )
                    } label: {
                        HorizontalMenuCardView(
                            title: "Favorites",
                            subtitle: "\(favoriteQuotes.count) saved quote\(favoriteQuotes.count == 1 ? "" : "s")",
                            iconName: "heart.fill",
                            selectedAppearance: selectedAppearance
                        )
                    }

                    NavigationLink {
                        HistoryView(
                            focusHistory: $focusHistory,
                            selectedAppearance: $selectedAppearance
                        )
                    } label: {
                        HorizontalMenuCardView(
                            title: "History",
                            subtitle: "\(focusHistory.count) completed session\(focusHistory.count == 1 ? "" : "s")",
                            iconName: "clock.arrow.circlepath",
                            selectedAppearance: selectedAppearance
                        )
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

struct HorizontalMenuCardView: View {
    let title: String
    let subtitle: String
    let iconName: String
    let selectedAppearance: ThemeOption

    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(currentTheme.accent.opacity(0.18))
                    .frame(width: 56, height: 56)

                Image(systemName: iconName)
                    .foregroundColor(currentTheme.accent)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .foregroundColor(currentTheme.primaryText)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .foregroundColor(currentTheme.secondaryText)
                    .font(.subheadline)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(currentTheme.secondaryText)
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(currentTheme.cardBackground)
        .cornerRadius(24)
    }
}

