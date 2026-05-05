import SwiftUI

// MARK: - HISTORY VIEW
// HistoryView shows a list of completed focus timer sessions.
// Every time the user finishes a timer session, it can appear on this screen.

struct HistoryView: View {

    // Allows this view to close itself and go back to the previous screen.
    @Environment(\.dismiss) var dismiss

    // focusHistory is passed in from another view.
    // Because it is a Binding, this view can read the same history data used elsewhere in the app.
    @Binding var focusHistory: [FocusSession]

    // The selected theme is also passed in so this screen matches the rest of the app.
    @Binding var selectedAppearance: ThemeOption

    // Gets the correct colors for the currently selected theme.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        ZStack {

            // Sets the background color based on the selected theme.
            currentTheme.background.ignoresSafeArea()

            // ScrollView allows the user to scroll if there are many focus sessions.
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - HEADER

                    ZStack {
                        HStack {

                            // Custom back button on the left.
                            backButton

                            Spacer()
                        }

                        // Centered page title.
                        Text("History")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top)


                    // MARK: - EMPTY STATE OR HISTORY LIST

                    // If the user has not completed any focus sessions yet,
                    // the app shows a friendly empty message.
                    if focusHistory.isEmpty {
                        EmptyStateView(
                            iconName: "clock.badge.xmark",
                            title: "No focus sessions yet",
                            subtitle: "Complete a timer session and it will appear here.",
                            selectedAppearance: selectedAppearance
                        )
                        .padding(.top, 20)
                    } else {

                        // If there are completed sessions, display each one as a card.
                        ForEach(focusHistory) { session in
                            HistoryCardView(
                                session: session,
                                selectedAppearance: selectedAppearance
                            )
                        }
                    }
                }
                .padding()
            }
        }

        // Hides the default iOS back button because this screen uses a custom one.
        .navigationBarBackButtonHidden(true)
    }


    // MARK: - CUSTOM BACK BUTTON

    // Creates a reusable back button for the top-left corner.
    var backButton: some View {
        Button(action: { dismiss() }) {
            ZStack {

                // Circular button background.
                Circle()
                    .fill(currentTheme.cardBackground)
                    .frame(width: 56, height: 56)

                // Back arrow icon.
                Image(systemName: "chevron.left")
                    .foregroundColor(currentTheme.primaryText)
                    .font(.title2)
            }
        }
    }
}


// MARK: - HISTORY CARD VIEW
// HistoryCardView displays one completed focus session.

struct HistoryCardView: View {

    // The completed focus session being displayed.
    let session: FocusSession

    // The selected theme used to style the card.
    let selectedAppearance: ThemeOption

    // Gets the current theme colors.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Shows the length of the completed focus session.
            Text("Completed \(formattedSessionLength(session.durationSeconds)) focus session")
                .foregroundColor(currentTheme.primaryText)
                .font(.headline)

            // Shows the date and time the session was completed.
            Text(formatSessionDate(session.completedAt))
                .foregroundColor(currentTheme.secondaryText)
                .font(.subheadline)
        }
        .padding()

        // Makes the card stretch across the screen.
        .frame(maxWidth: .infinity, alignment: .leading)

        // Gives the card a theme-based background.
        .background(currentTheme.cardBackground)

        // Rounds the card corners.
        .cornerRadius(18)
    }


    // MARK: - FORMAT SESSION LENGTH

    // Converts the session length from seconds into readable text.
    // Example: 90 seconds becomes "1 min 30 sec".
    func formattedSessionLength(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60

        if hours > 0 && minutes > 0 {
            return "\(hours) hr \(minutes) min"
        } else if hours > 0 {
            return "\(hours) hr"
        } else if minutes > 0 && remainingSeconds > 0 {
            return "\(minutes) min \(remainingSeconds) sec"
        } else if minutes > 0 {
            return "\(minutes) min"
        } else if remainingSeconds == 1 {
            return "1 second"
        } else {
            return "\(remainingSeconds) seconds"
        }
    }


    // MARK: - FORMAT SESSION DATE

    // Converts the completed session date into readable text.
    // Example: "Mon, May 4, 2026 • 3:30 PM"
    func formatSessionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy • h:mm a"
        return formatter.string(from: date)
    }
}
