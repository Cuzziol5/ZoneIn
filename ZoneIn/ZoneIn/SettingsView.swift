import SwiftUI

// MARK: - CHANGE NAME VIEW
// This screen allows the user to update their profile name.

struct ChangeNameView: View {

    // Allows this screen to close and return to the previous screen.
    @Environment(\.dismiss) var dismiss

    // Binding connects this view to the userName stored in another view.
    // When this screen changes userName, the change updates everywhere else.
    @Binding var userName: String

    // Binding for the current app theme.
    @Binding var selectedAppearance: ThemeOption

    // Gets the correct colors for the selected theme.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        ZStack {

            // Sets the background color for the full screen.
            currentTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                // MARK: - HEADER

                ZStack {
                    HStack {
                        backButton
                        Spacer()
                    }

                    Text("Change Name")
                        .foregroundColor(currentTheme.primaryText)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top)

                // MARK: - NAME INPUT

                VStack(alignment: .leading, spacing: 14) {
                    Text("Name")
                        .foregroundColor(currentTheme.primaryText)
                        .font(.headline)

                    // TextField allows the user to type and edit their name.
                    TextField("Enter your name", text: $userName)
                        .padding()
                        .background(currentTheme.cardBackground)
                        .foregroundColor(currentTheme.primaryText)
                        .cornerRadius(16)
                }

                // MARK: - SAVE BUTTON

                Button(action: {

                    // If the user leaves the name empty, the app sets it to "User".
                    if userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        userName = "User"
                    }

                    // Closes the screen after saving.
                    dismiss()
                }) {
                    Text("Save Name")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(currentTheme.accent)
                        .cornerRadius(16)
                }

                Spacer()
            }
            .padding()
        }

        // Hides the default iOS back button because the app uses a custom one.
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - CUSTOM BACK BUTTON

    // Reusable custom back button used at the top of the screen.
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


// MARK: - NOTIFICATIONS VIEW
// This screen lets the user turn daily reminders on/off and choose a reminder time.

struct NotificationsView: View {

    // Allows the screen to be dismissed.
    @Environment(\.dismiss) var dismiss

    // Stores whether notifications are enabled.
    @Binding var notificationsEnabled: Bool

    // Stores the selected reminder time.
    @Binding var reminderTime: Date

    // Stores the message shown to the user about notification status.
    @Binding var notificationStatusMessage: String

    // Stores the selected theme.
    @Binding var selectedAppearance: ThemeOption

    // Gets theme colors based on the selected appearance.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        ZStack {

            // Full-screen themed background.
            currentTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                // MARK: - HEADER

                ZStack {
                    HStack {
                        backButton
                        Spacer()
                    }

                    Text("Notifications")
                        .foregroundColor(currentTheme.primaryText)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top)

                // MARK: - DAILY REMINDER TOGGLE

                Toggle(isOn: $notificationsEnabled) {
                    Text("Daily Reminder")
                        .foregroundColor(currentTheme.primaryText)
                        .font(.headline)
                }
                .tint(currentTheme.accent)
                .padding()
                .background(currentTheme.cardBackground)
                .cornerRadius(18)

                // Runs when the toggle is turned on or off.
                .onChange(of: notificationsEnabled) { _, isEnabled in
                    handleNotificationToggle(isEnabled)
                }

                // MARK: - REMINDER TIME PICKER

                // Only show the time picker if daily reminders are enabled.
                if notificationsEnabled {
                    VStack(spacing: 14) {
                        Text("Reminder Time")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.headline)

                        HStack {
                            Spacer()

                            // Lets the user select the time for their daily reminder.
                            DatePicker(
                                "Select Time",
                                selection: $reminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()

                            // Makes the DatePicker easier to see depending on the selected theme.
                            .colorScheme(selectedAppearance == .white ? .light : .dark)
                            .frame(width: 220)

                            Spacer()
                        }

                        // Schedules the notification for the selected time.
                        Button(action: {
                            setDailyReminder()
                        }) {
                            Text("Set Reminder")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(currentTheme.accent)
                                .cornerRadius(14)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(currentTheme.cardBackground)
                    .cornerRadius(18)
                }

                // MARK: - NOTIFICATION STATUS MESSAGE

                VStack(alignment: .leading, spacing: 10) {
                    Text("Status")
                        .foregroundColor(currentTheme.primaryText)
                        .font(.headline)

                    // Shows messages like permission granted, disabled, or reminder set.
                    Text(notificationStatusMessage)
                        .foregroundColor(currentTheme.secondaryText)
                        .font(.body)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(currentTheme.cardBackground)
                .cornerRadius(18)

                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)

        // Checks the current iPhone notification permission when the screen opens.
        .onAppear {
            checkNotificationStatus()
        }
    }

    // MARK: - NOTIFICATION FUNCTIONS

    // Checks whether the app currently has permission to send notifications.
    func checkNotificationStatus() {
        NotificationManager.checkAuthorizationStatus { status in
            switch status {

            // Notifications are allowed.
            case .authorized, .provisional, .ephemeral:
                if notificationsEnabled {
                    if notificationStatusMessage == "Notifications are currently off." {
                        notificationStatusMessage = "Choose a time and tap Set Reminder."
                    }
                } else {
                    notificationStatusMessage = "Notifications are allowed. Turn on Daily Reminder to use them."
                }

            // User denied notification permission in iPhone Settings.
            case .denied:
                notificationsEnabled = false
                notificationStatusMessage = "Notifications are disabled in iPhone Settings for this app."

            // User has not been asked for notification permission yet.
            case .notDetermined:
                notificationStatusMessage = "Notification permission has not been requested yet."

            // Backup case for possible future notification permission states.
            @unknown default:
                notificationStatusMessage = "Unable to determine notification status."
            }
        }
    }

    // Handles what happens when the user turns the daily reminder toggle on or off.
    func handleNotificationToggle(_ isEnabled: Bool) {

        // If the user turns notifications on, check permission first.
        if isEnabled {
            NotificationManager.checkAuthorizationStatus { status in
                switch status {

                // Permission already exists.
                case .authorized, .provisional, .ephemeral:
                    notificationStatusMessage = "Choose a time and tap Set Reminder."

                // Permission has not been requested yet, so the app asks the user.
                case .notDetermined:
                    NotificationManager.requestPermission { granted in
                        if granted {
                            notificationStatusMessage = "Permission granted. Choose a time and tap Set Reminder."
                        } else {
                            notificationsEnabled = false
                            notificationStatusMessage = "Permission was not granted."
                        }
                    }

                // Permission was denied, so the app cannot schedule notifications.
                case .denied:
                    notificationsEnabled = false
                    notificationStatusMessage = "Notifications are disabled in iPhone Settings for this app."

                // Backup case.
                @unknown default:
                    notificationsEnabled = false
                    notificationStatusMessage = "Unable to determine notification status."
                }
            }

        } else {

            // If the user turns reminders off, cancel the scheduled daily reminder.
            NotificationManager.cancelDailyReminder()
            notificationStatusMessage = "Daily reminders have been turned off."
        }
    }

    // Runs when the user taps "Set Reminder."
    func setDailyReminder() {
        NotificationManager.checkAuthorizationStatus { status in
            switch status {

            // If permission is already allowed, schedule the reminder.
            case .authorized, .provisional, .ephemeral:
                scheduleReminder(at: reminderTime)

            // If permission has not been requested, ask first.
            case .notDetermined:
                NotificationManager.requestPermission { granted in
                    if granted {
                        scheduleReminder(at: reminderTime)
                    } else {
                        notificationsEnabled = false
                        notificationStatusMessage = "Permission was not granted."
                    }
                }

            // If permission is denied, show a message and turn the toggle off.
            case .denied:
                notificationsEnabled = false
                notificationStatusMessage = "Notifications are disabled in iPhone Settings for this app."

            // Backup case.
            @unknown default:
                notificationStatusMessage = "Unable to determine notification status."
            }
        }
    }

    // Actually schedules the daily reminder notification using NotificationManager.
    func scheduleReminder(at date: Date) {
        NotificationManager.scheduleDailyReminder(at: date) { error in

            // UI updates should happen on the main thread.
            DispatchQueue.main.async {

                // If scheduling failed, show the error message.
                if let error = error {
                    notificationStatusMessage = "Failed to schedule reminder: \(error.localizedDescription)"
                } else {

                    // Formats the selected time into a readable format.
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short

                    // Shows confirmation to the user.
                    notificationStatusMessage = "Daily reminders are set for \(formatter.string(from: date)) with rotating quotes."
                }
            }
        }
    }

    // MARK: - CUSTOM BACK BUTTON

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


// MARK: - THEME VIEW
// This screen allows the user to switch between ZoneIn's themes.

struct ThemeView: View {

    // Allows the screen to close.
    @Environment(\.dismiss) var dismiss

    // Binding for the selected theme.
    // Changing this updates the theme across the app.
    @Binding var selectedAppearance: ThemeOption

    // Gets the current colors for the selected theme.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        ZStack {

            // Applies the selected background theme.
            currentTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                // MARK: - HEADER

                ZStack {
                    HStack {
                        backButton
                        Spacer()
                    }

                    Text("Theme")
                        .foregroundColor(currentTheme.primaryText)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top)

                Text("Choose Theme")
                    .foregroundColor(currentTheme.primaryText)
                    .font(.title2)
                    .fontWeight(.semibold)

                // MARK: - THEME OPTIONS

                VStack(spacing: 14) {

                    // Loops through every theme option in ThemeOption.
                    ForEach(ThemeOption.allCases, id: \.self) { option in

                        // Each theme appears as a button.
                        Button(action: {

                            // Updates the selected theme.
                            selectedAppearance = option
                        }) {
                            HStack {
                                Text(option.rawValue)
                                    .foregroundColor(currentTheme.primaryText)

                                Spacer()

                                // Shows a checkmark next to the currently selected theme.
                                if selectedAppearance == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(currentTheme.accent)
                                }
                            }
                            .padding()
                            .background(currentTheme.cardBackground)
                            .cornerRadius(18)
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - CUSTOM BACK BUTTON

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


// MARK: - HELP VIEW
// This screen gives users basic help information and explains app features.

struct HelpSupportView: View {

    // Allows the screen to close.
    @Environment(\.dismiss) var dismiss

    // Binding for the current theme.
    @Binding var selectedAppearance: ThemeOption

    // Gets theme colors.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        ZStack {

            // Full-screen themed background.
            currentTheme.background.ignoresSafeArea()

            // ScrollView allows the content to scroll if it does not fit on smaller screens.
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - HEADER

                    ZStack {
                        HStack {
                            backButton
                            Spacer()
                        }

                        Text("Help")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top)

                    // MARK: - FAQ SECTION

                    Text("FAQ")
                        .foregroundColor(currentTheme.primaryText)
                        .font(.title2)
                        .fontWeight(.semibold)

                    // Reusable help cards explaining each major feature.
                    HelpCardView(
                        question: "What does ZoneIn do?",
                        answer: "ZoneIn helps users stay focused by combining motivational quotes, focus sessions, favorites, reminders, and distraction-reducing tools.",
                        selectedAppearance: selectedAppearance
                    )

                    HelpCardView(
                        question: "How do I save a quote?",
                        answer: "Tap the heart under a quote or double tap the quote to save it to your Favorites.",
                        selectedAppearance: selectedAppearance
                    )

                    HelpCardView(
                        question: "How does the timer work?",
                        answer: "Choose a focus duration, start the session, and ZoneIn will track it when the timer is completed.",
                        selectedAppearance: selectedAppearance
                    )

                    HelpCardView(
                        question: "What is App Blocking?",
                        answer: "App Blocking lets users select distracting apps, categories, and websites. Full device-level blocking requires Apple's restricted Family Controls entitlement.",
                        selectedAppearance: selectedAppearance
                    )

                    // MARK: - APP INFO SECTION

                    Text("App Info")
                        .foregroundColor(currentTheme.primaryText)
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 12) {
                        Label("ZoneIn Version 1.0", systemImage: "info.circle")
                            .foregroundColor(currentTheme.primaryText)

                        Label("Stay focused. Enter your zone.", systemImage: "bolt.fill")
                            .foregroundColor(currentTheme.primaryText)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(currentTheme.cardBackground)
                    .cornerRadius(20)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - CUSTOM BACK BUTTON

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


// MARK: - HELP CARD VIEW
// A reusable card component for displaying FAQ questions and answers.

struct HelpCardView: View {

    // The question shown at the top of the card.
    let question: String

    // The answer shown below the question.
    let answer: String

    // The selected theme passed in from the Help screen.
    let selectedAppearance: ThemeOption

    // Gets theme colors for this card.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // FAQ question.
            Text(question)
                .foregroundColor(currentTheme.primaryText)
                .font(.headline)

            // FAQ answer.
            Text(answer)
                .foregroundColor(currentTheme.secondaryText)
                .font(.body)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(currentTheme.cardBackground)
        .cornerRadius(20)
    }
}
