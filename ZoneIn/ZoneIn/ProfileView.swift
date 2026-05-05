import SwiftUI
import PhotosUI
import UIKit // Used to convert saved profile image data into an image that SwiftUI can display. (Older iOS user interface framework.)

// MARK: - PROFILE

// ProfileView is the profile/settings screen for ZoneIn.
// It shows the user's profile picture, name, stats, settings, and a reminder quote.
struct ProfileView: View {
    
    // Allows this screen to close and go back to the previous screen.
    @Environment(\.dismiss) var dismiss

    // These are connected to ContentView using @Binding.
    // That means ProfileView can read and update the same data from the main screen.
    @Binding var favoriteQuotes: [FavoriteQuote]
    @Binding var focusHistory: [FocusSession]

    // These values are passed in to show quick stats.
    let favoriteCount: Int
    let sessionCount: Int

    // User settings passed from ContentView.
    @Binding var userName: String
    @Binding var notificationsEnabled: Bool
    @Binding var reminderTime: Date
    @Binding var notificationStatusMessage: String
    @Binding var selectedAppearance: ThemeOption
    @Binding var profileImageData: Data

    // Stores the photo selected from the user's photo library.
    @State private var selectedPhotoItem: PhotosPickerItem?

    // List of random reminder messages shown near the bottom of the profile screen.
    let reminders = [
        "Discipline is not about feeling ready. It is about showing up anyway.",
        "Focus is built one decision at a time.",
        "The goal is not motivation every day. The goal is consistency.",
        "Stay focused. Enter your zone.",
        "Serious progress starts when distractions stop."
    ]

    // Stores the reminder currently displayed on the screen.
    @State private var currentReminder = ""

    // Gets the current theme colors based on the selected theme.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    // If the user has not entered a name, the app displays "User".
    var displayName: String {
        userName.isEmpty ? "User" : userName
    }

    // MARK: - BODY / USER INTERFACE

    var body: some View {
        ZStack {
            
            // Sets the background color based on the selected theme.
            currentTheme.background.ignoresSafeArea()

            // Allows the profile page to scroll if the content does not fit on screen.
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // MARK: - HEADER

                    ZStack {
                        HStack {
                            backButton
                            Spacer()
                        }

                        Text("Profile")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top)

                    // MARK: - PROFILE PHOTO AND NAME SECTION

                    VStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            
                            // Shows either the user's selected image or their first initial.
                            profileImageView

                            // Lets the user pick a profile photo from their photo library.
                            PhotosPicker(
                                selection: $selectedPhotoItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                ZStack {
                                    Circle()
                                        .fill(currentTheme.accent)
                                        .frame(width: 34, height: 34)

                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 15, weight: .bold))
                                }
                            }
                        }

                        // Shows the remove photo button only if the user has a photo selected.
                        if !profileImageData.isEmpty {
                            Button(action: {
                                
                                // Clears the saved image data.
                                profileImageData = Data()
                                selectedPhotoItem = nil
                            }) {
                                Text("Remove Photo")
                                    .foregroundColor(currentTheme.accent)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }

                        VStack(spacing: 6) {
                            Text(displayName)
                                .foregroundColor(currentTheme.primaryText)
                                .font(.title)
                                .fontWeight(.semibold)

                            Text("Stay focused. Enter your zone.")
                                .foregroundColor(currentTheme.secondaryText)
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                    // MARK: - USER STATS SECTION

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Stats")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.title2)
                            .fontWeight(.semibold)

                        HStack(spacing: 16) {
                            
                            // Opens the Favorites screen.
                            NavigationLink {
                                FavoritesView(
                                    favoriteQuotes: $favoriteQuotes,
                                    selectedAppearance: $selectedAppearance
                                )
                            } label: {
                                ProfileStatCard(
                                    title: "Favorites",
                                    value: "\(favoriteCount)",
                                    iconName: "heart.fill",
                                    iconColor: .red,
                                    selectedAppearance: selectedAppearance
                                )
                            }

                            // Opens the Focus History screen.
                            NavigationLink {
                                HistoryView(
                                    focusHistory: $focusHistory,
                                    selectedAppearance: $selectedAppearance
                                )
                            } label: {
                                ProfileStatCard(
                                    title: "Sessions",
                                    value: "\(sessionCount)",
                                    iconName: "timer",
                                    iconColor: currentTheme.accent,
                                    selectedAppearance: selectedAppearance
                                )
                            }
                        }
                    }

                    // MARK: - ACCOUNT / SETTINGS SECTION

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.title2)
                            .fontWeight(.semibold)

                        VStack(spacing: 14) {
                            
                            // Opens the screen where the user can change their name.
                            NavigationLink {
                                ChangeNameView(
                                    userName: $userName,
                                    selectedAppearance: $selectedAppearance
                                )
                            } label: {
                                ProfileRowView(
                                    iconName: "person.text.rectangle",
                                    title: "Change Name",
                                    selectedAppearance: selectedAppearance
                                )
                            }

                            // Opens the notification settings screen.
                            NavigationLink {
                                NotificationsView(
                                    notificationsEnabled: $notificationsEnabled,
                                    reminderTime: $reminderTime,
                                    notificationStatusMessage: $notificationStatusMessage,
                                    selectedAppearance: $selectedAppearance
                                )
                            } label: {
                                ProfileRowView(
                                    iconName: "bell",
                                    title: "Notifications",
                                    selectedAppearance: selectedAppearance
                                )
                            }

                            // Opens the theme selection screen.
                            NavigationLink {
                                ThemeView(selectedAppearance: $selectedAppearance)
                            } label: {
                                ProfileRowView(
                                    iconName: "paintbrush",
                                    title: "Theme",
                                    selectedAppearance: selectedAppearance
                                )
                            }

                            // Opens the help/support screen.
                            NavigationLink {
                                HelpSupportView(selectedAppearance: $selectedAppearance)
                            } label: {
                                ProfileRowView(
                                    iconName: "questionmark.circle",
                                    title: "Help",
                                    selectedAppearance: selectedAppearance
                                )
                            }
                        }
                    }

                    // MARK: - RANDOM REMINDER SECTION

                    VStack(alignment: .leading, spacing: 16) {
                        Text("ZoneIn Reminder")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.title2)
                            .fontWeight(.semibold)

                        // Displays a random reminder message when the profile screen opens.
                        Text(currentReminder)
                            .foregroundColor(currentTheme.primaryText)
                            .font(.system(size: 20, weight: .medium))
                            .multilineTextAlignment(.center)
                            .padding(22)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(currentTheme.cardBackground)
                            .cornerRadius(26)
                    }
                }
                .padding()
            }
        }
        
        // Hides the default back button because the app uses a custom back button.
        .navigationBarBackButtonHidden(true)
        
        // Runs when the profile screen appears.
        .onAppear {
            
            // Picks one random reminder from the reminders array.
            currentReminder = reminders.randomElement() ?? reminders[0]
        }
        
        // Runs when the user selects a new profile photo.
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                
                // Loads the selected image as Data.
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        
                        // Saves the image data so it can be displayed and remembered.
                        profileImageData = data
                    }
                }
            }
        }
    }

    // MARK: - PROFILE IMAGE VIEW

    // Displays the user's profile image.
    // If no image exists, it displays the first letter of the user's name.
    var profileImageView: some View {
        ZStack {
            Circle()
                .fill(currentTheme.cardBackground)
                .frame(width: 116, height: 116)

            if let uiImage = UIImage(data: profileImageData), !profileImageData.isEmpty {
                
                // Converts the saved image data into a SwiftUI image.
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 108, height: 108)
                    .clipShape(Circle())
            } else {
                
                // Shows the user's first initial if there is no profile photo.
                Text(String(displayName.prefix(1)).uppercased())
                    .foregroundColor(currentTheme.primaryText)
                    .font(.system(size: 46, weight: .bold))
            }
        }
    }

    // MARK: - BACK BUTTON

    // Custom back button used instead of the default navigation back button.
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

// MARK: - PROFILE STAT CARD

// Reusable card used for stats like Favorites and Sessions.
struct ProfileStatCard: View {
    let title: String
    let value: String
    let iconName: String
    let iconColor: Color
    let selectedAppearance: ThemeOption

    // Gets theme colors for this card.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.title3)

                Spacer()
            }

            // Displays the stat number.
            Text(value)
                .foregroundColor(currentTheme.primaryText)
                .font(.system(size: 28, weight: .bold))

            // Displays the stat label.
            Text(title)
                .foregroundColor(currentTheme.secondaryText)
                .font(.subheadline)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
        .background(currentTheme.cardBackground)
        .cornerRadius(26)
    }
}

// MARK: - PROFILE WIDE STAT CARD

// This is another reusable stat card layout.
// It is not currently used in ProfileView, but it could be used for wider profile rows later.
struct ProfileWideStatCard: View {
    let title: String
    let value: String
    let iconName: String
    let selectedAppearance: ThemeOption

    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(currentTheme.accent.opacity(0.18))
                    .frame(width: 50, height: 50)

                Image(systemName: iconName)
                    .foregroundColor(currentTheme.accent)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(currentTheme.primaryText)
                    .font(.headline)

                Text(value)
                    .foregroundColor(currentTheme.secondaryText)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding()
        .background(currentTheme.cardBackground)
        .cornerRadius(22)
    }
}

// MARK: - PROFILE ROW VIEW

// Reusable row used in the Account section.
// Examples: Change Name, Notifications, Theme, Help.
struct ProfileRowView: View {
    let iconName: String
    let title: String
    let selectedAppearance: ThemeOption

    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(currentTheme.cardBackground)
                    .frame(width: 46, height: 46)

                Image(systemName: iconName)
                    .foregroundColor(currentTheme.primaryText)
                    .font(.system(size: 18))
            }

            Text(title)
                .foregroundColor(currentTheme.primaryText)
                .font(.body)

            Spacer()

            // Shows that the row opens another screen.
            Image(systemName: "chevron.right")
                .foregroundColor(currentTheme.secondaryText)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(18)
        .background(currentTheme.secondaryBackground)
        .cornerRadius(22)
    }
}
