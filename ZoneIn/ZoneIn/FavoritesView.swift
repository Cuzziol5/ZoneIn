import SwiftUI

// MARK: - FAVORITES VIEW
// FavoritesView displays all quotes the user has saved.
// Users can remove quotes from favorites or share them.
struct FavoritesView: View {
    
    // Allows this screen to close and go back to the previous screen.
    @Environment(\.dismiss) var dismiss

    // Binding connects this view to the favoriteQuotes array from ContentView.
    // If a favorite is removed here, it also updates the main app data.
    @Binding var favoriteQuotes: [FavoriteQuote]
    
    // Binding connects this view to the selected theme.
    // This allows the Favorites screen to match the rest of the app's appearance.
    @Binding var selectedAppearance: ThemeOption

    // Gets the correct colors for the currently selected theme.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        ZStack {
            
            // Sets the screen background based on the selected theme.
            currentTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - HEADER
                    
                    ZStack {
                        HStack {
                            backButton
                            Spacer()
                        }

                        Text("Favorites")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top)

                    // MARK: - EMPTY STATE OR FAVORITES LIST
                    
                    if favoriteQuotes.isEmpty {
                        
                        // Shows a message when the user has not saved any quotes yet.
                        EmptyStateView(
                            iconName: "heart.slash",
                            title: "No favorites yet",
                            subtitle: "Tap the heart under any quote or double tap the quote to save it here.",
                            selectedAppearance: selectedAppearance
                        )
                        .padding(.top, 20)
                    } else {
                        
                        // Displays saved quotes in reverse order.
                        // This means the most recently saved quote appears first.
                        ForEach(Array(favoriteQuotes.reversed()), id: \.id) { favorite in
                            FavoriteCardView(
                                favorite: favorite,
                                onRemove: {
                                    removeFavorite(favorite)
                                },
                                selectedAppearance: selectedAppearance
                            )
                        }
                    }
                }
                .padding()
            }
        }
        
        // Hides the default iOS back button because the app uses its own custom back button.
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - REMOVE FAVORITE FUNCTION
    
    // Removes a selected quote from the favorites array.
    func removeFavorite(_ quote: FavoriteQuote) {
        if let index = favoriteQuotes.firstIndex(of: quote) {
            favoriteQuotes.remove(at: index)
        }
    }

    // MARK: - CUSTOM BACK BUTTON
    
    // Custom circular back button used instead of the default navigation back button.
    var backButton: some View {
        Button(action: { dismiss() }) {
            ZStack {
                Circle()
                    .fill(currentTheme.cardBackground)
                    .frame(width: 56, height: 56)

                Image(systemName: "chevron.left")
                    .foregroundColor(currentTheme.primaryText)
                    .font(.title2)
            }
        }
    }
}


// MARK: - FAVORITE CARD VIEW
// FavoriteCardView controls the design of each individual saved quote card.
struct FavoriteCardView: View {
    
    // The saved quote being displayed.
    let favorite: FavoriteQuote
    
    // Function passed in from FavoritesView.
    // This lets the card tell the parent view to remove the quote.
    let onRemove: () -> Void
    
    // The currently selected theme.
    let selectedAppearance: ThemeOption

    // Gets the correct colors for the selected theme.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    // Text used when the user shares a favorited quote.
    var shareText: String {
        """
        "\(favorite.text)"

        Shared from ZoneIn.
        Stay focused. Enter your zone.

        Download ZoneIn: https://zonein.app
        """
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            
            // Displays the saved quote text.
            Text(favorite.text)
                .foregroundColor(currentTheme.primaryText)
                .font(.system(size: 22, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                
                // Shows the date the quote was saved.
                Text(formatFavoriteDate(favorite.dateSaved))
                    .foregroundColor(currentTheme.secondaryText)
                    .font(.subheadline)

                Spacer()

                // Removes the quote from favorites.
                Button(action: {
                    onRemove()
                }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }

                // Opens the iOS share sheet to share the quote.
                ShareLink(
                    item: shareText,
                    subject: Text("ZoneIn Quote"),
                    message: Text(favorite.text),
                    preview: SharePreview("ZoneIn Quote", image: Image(systemName: "bolt.fill"))
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(currentTheme.primaryText)
                        .font(.title3)
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(currentTheme.cardBackground)
        .cornerRadius(26)
    }

    // MARK: - DATE FORMATTER
    
    // Converts the saved Date into a readable format.
    // Example: Mon, Feb 4, 2026
    func formatFavoriteDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
}
