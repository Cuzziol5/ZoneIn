import SwiftUI

// MARK: - ONBOARDING VIEW
// This screen appears the first time a user opens ZoneIn.
// It introduces the app, asks for the user's name, and gives the option to allow notifications.
struct OnboardingView: View {

    // MARK: - BINDINGS FROM CONTENTVIEW

    // @Binding means this view can read and update data owned by another view.
    // These values come from ContentView.

    // Tracks whether the user has completed onboarding.
    @Binding var hasSeenOnboarding: Bool

    // Stores the user's name.
    @Binding var userName: String

    // Stores whether the user allowed notifications.
    @Binding var notificationsEnabled: Bool

    // Stores the selected daily reminder time.
    @Binding var reminderTime: Date

    // Stores a message explaining the notification status.
    @Binding var notificationStatusMessage: String

    // Stores the selected app theme.
    @Binding var selectedAppearance: ThemeOption


    // MARK: - LOCAL STATE

    // Temporarily stores the name typed into the text field.
    @State private var enteredName = ""

    // Tracks whether the name text field is currently selected.
    // This lets the app control the keyboard.
    @FocusState private var isNameFieldFocused: Bool


    // MARK: - THEME

    // Gets the colors for the currently selected theme.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }


    // MARK: - BODY / USER INTERFACE

    var body: some View {
        ZStack {

            // Sets the full-screen background color based on the selected theme.
            currentTheme.background.ignoresSafeArea()

            // ScrollView allows the onboarding screen to fit on smaller phones.
            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 35)

                    // Displays the ZoneIn app logo.
                    Image("ZoneInLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .cornerRadius(26)
                        .shadow(color: currentTheme.accent.opacity(0.35), radius: 12, x: 0, y: 5)

                    // Main welcome title.
                    Text("Welcome to ZoneIn")
                        .foregroundColor(currentTheme.primaryText)
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)

                    // Short slogan for the app.
                    Text("Stay focused. Enter your zone.")
                        .foregroundColor(currentTheme.accent)
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    // Brief explanation of what ZoneIn helps the user do.
                    Text("Build focus, save motivation, and track your discipline one session at a time.")
                        .foregroundColor(currentTheme.secondaryText)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)


                    // MARK: - FEATURE CARDS

                    // Shows the main features of the app in simple cards.
                    VStack(spacing: 16) {

                        // Card explaining the motivational quote feature.
                        OnboardingCard(
                            icon: "quote.bubble",
                            title: "Motivation",
                            text: "Swipe through quotes built to keep you motivated.",
                            selectedAppearance: selectedAppearance
                        )

                        // Card explaining the focus timer feature.
                        OnboardingCard(
                            icon: "timer",
                            title: "Focus Timer",
                            text: "Set a focus session, stay locked in, and track the time you spend building discipline.",
                            selectedAppearance: selectedAppearance
                        )

                        // Card explaining the planned app blocking feature.
                        OnboardingCard(
                            icon: "lock.shield",
                            title: "App Blocking",
                            text: "Coming soon! Choose distracting apps and block them during focus sessions.",
                            selectedAppearance: selectedAppearance
                        )
                    }
                    .padding(.horizontal)


                    // MARK: - NAME INPUT SECTION

                    VStack(alignment: .leading, spacing: 10) {
                        Text("What should we call you?")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.headline)

                        // Text field where the user enters their name.
                        TextField("Enter your name", text: $enteredName)
                            .padding()
                            .background(currentTheme.cardBackground)
                            .foregroundColor(currentTheme.primaryText)
                            .cornerRadius(16)

                            // Connects this text field to the FocusState.
                            .focused($isNameFieldFocused)

                            // Changes the keyboard return button to "Done".
                            .submitLabel(.done)

                            // Hides the keyboard when the user presses Done.
                            .onSubmit {
                                isNameFieldFocused = false
                            }

                            // Adds a Done button above the keyboard.
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()

                                    Button("Done") {
                                        isNameFieldFocused = false
                                    }
                                    .foregroundColor(currentTheme.accent)
                                }
                            }
                    }
                    .padding(.horizontal, 30)


                    // MARK: - NOTIFICATION / FINISH BUTTONS

                    VStack(spacing: 12) {

                        // Requests notification permission and then finishes onboarding.
                        Button(action: {
                            requestNotificationsAndFinish()
                        }) {
                            Text("Allow Notifications")
                                .foregroundColor(.white)
                                .font(.system(size: 17, weight: .semibold))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(currentTheme.accent)
                                .cornerRadius(18)
                                .padding(.horizontal, 30)
                        }

                        // Lets the user skip notification permission.
                        Button(action: {
                            finishOnboarding()
                        }) {
                            Text("Not Now")
                                .foregroundColor(currentTheme.primaryText)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }

                    Spacer(minLength: 35)
                }
            }
        }

        // When the onboarding screen appears, load the existing username if there is one.
        .onAppear {
            enteredName = userName
        }
    }


    // MARK: - NOTIFICATION FUNCTION

    // Requests notification permission from the user.
    // If permission is granted, it schedules a daily reminder.
    // Then it finishes onboarding.
    func requestNotificationsAndFinish() {
        NotificationManager.requestPermission { granted in

            // Stores whether permission was granted.
            notificationsEnabled = granted

            if granted {

                // If notifications are allowed, schedule the daily reminder.
                NotificationManager.scheduleDailyReminder(at: reminderTime) { error in

                    // UI updates should happen on the main thread.
                    DispatchQueue.main.async {
                        if error == nil {

                            // Formats the reminder time into a readable format.
                            let formatter = DateFormatter()
                            formatter.timeStyle = .short

                            // Updates the status message shown in settings/profile.
                            notificationStatusMessage = "Daily reminders are set for \(formatter.string(from: reminderTime)) with rotating quotes."
                        } else {
                            notificationStatusMessage = "Notifications were allowed, but the reminder could not be scheduled."
                        }

                        // Finishes onboarding after scheduling the reminder.
                        finishOnboarding()
                    }
                }
            } else {

                // If permission is denied, store that status and finish onboarding.
                notificationStatusMessage = "Notifications were not allowed."
                finishOnboarding()
            }
        }
    }


    // MARK: - FINISH ONBOARDING FUNCTION

    // Saves the user's name and marks onboarding as complete.
    func finishOnboarding() {

        // Removes extra spaces before and after the name.
        let trimmedName = enteredName.trimmingCharacters(in: .whitespacesAndNewlines)

        // If the user typed a name, save it.
        if !trimmedName.isEmpty {
            userName = trimmedName
        }

        // If no name exists, use a default name.
        else if userName.isEmpty {
            userName = "User"
        }

        // Marks onboarding as complete.
        // This prevents the onboarding screen from showing every time the app opens.
        hasSeenOnboarding = true
    }
}


// MARK: - ONBOARDING CARD

// Reusable card used to explain each main ZoneIn feature.
// This keeps the onboarding layout cleaner instead of rewriting the same card design three times.
struct OnboardingCard: View {

    // The SF Symbol icon shown on the card.
    let icon: String

    // The card title.
    let title: String

    // The card description.
    let text: String

    // The selected theme passed from OnboardingView.
    let selectedAppearance: ThemeOption

    // Gets the colors for the selected theme.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {

            // Feature icon.
            Image(systemName: icon)
                .foregroundColor(currentTheme.accent)
                .font(.title2)

            VStack(alignment: .leading, spacing: 6) {

                // Feature title.
                Text(title)
                    .foregroundColor(currentTheme.primaryText)
                    .font(.headline)

                // Feature description.
                Text(text)
                    .foregroundColor(currentTheme.secondaryText)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding() // adds space inside the card around the text and icon. Without it, the content would be too close to the edges.
        .background(currentTheme.cardBackground) // gives the card a background color based on the current theme. So if the user changes the theme, the card color changes too.
        .cornerRadius(20) // gives the card a background color based on the current theme. So if the user changes the theme, the card color changes too. Smaller number = sharper corner
    }
}
