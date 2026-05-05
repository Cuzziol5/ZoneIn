import SwiftUI
import FamilyControls
import ManagedSettings

// MARK: - APP BLOCKING
// This screen lets the user choose distracting apps/categories/websites
// and turn app blocking on or off.
// This is a prototype feature because full Screen Time app blocking
// requires Apple's restricted Family Controls entitlement.

struct AppBlockingView: View {

    // Allows this screen to close and return to the previous screen.
    @Environment(\.dismiss) var dismiss

    // MARK: - BINDINGS FROM CONTENTVIEW

    // The selected theme is passed in from ContentView.
    // Because this is a Binding, changes can be shared across screens.
    @Binding var selectedAppearance: ThemeOption

    // Stores the apps, categories, and websites selected by the user.
    // This comes from Apple's FamilyControls framework.
    @Binding var familyActivitySelection: FamilyActivitySelection

    // Tracks whether app blocking is currently turned on.
    @Binding var appBlockingEnabled: Bool

    // MARK: - LOCAL STATE

    // Controls whether Apple's app/category picker is shown.
    @State private var showFamilyActivityPicker = false

    // Message shown to the user explaining the current app blocking status.
    @State private var statusMessage = "Choose apps, then turn on App Blocking."

    // ManagedSettingsStore is used to apply or remove shield/blocking rules.
    let store = ManagedSettingsStore()

    // MARK: - COMPUTED PROPERTIES

    // Gets the correct colors for the selected theme.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    // Counts how many total distractions were selected.
    // This includes apps, app categories, and websites.
    var totalSelections: Int {
        familyActivitySelection.applicationTokens.count +
        familyActivitySelection.categoryTokens.count +
        familyActivitySelection.webDomainTokens.count
    }

    // MARK: - USER INTERFACE

    var body: some View {
        ZStack {

            // Background color changes based on the selected theme.
            currentTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - HEADER

                    ZStack {
                        HStack {
                            backButton
                            Spacer()
                        }

                        Text("App Blocking")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top)

                    // MARK: - INTRO CARD

                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .fill(currentTheme.accent.opacity(0.18))
                                .frame(width: 82, height: 82)

                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(currentTheme.accent)
                                .font(.system(size: 38))
                        }

                        Text("Distraction Control")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Choose distracting apps and turn on App Blocking whenever you want to lock in.")
                            .foregroundColor(currentTheme.secondaryText)
                            .font(.body)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(currentTheme.cardBackground)
                    .cornerRadius(26)

                    // MARK: - APP PICKER BUTTON

                    // Opens Apple's FamilyActivityPicker.
                    // This is where the user chooses apps, categories, or websites.
                    Button(action: {
                        statusMessage = "Opening app picker. Select distractions, then tap Done."
                        showFamilyActivityPicker = true
                    }) {
                        Label("Choose Apps to Block", systemImage: "apps.iphone")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.system(size: 16, weight: .semibold))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(currentTheme.cardBackground)
                            .cornerRadius(16)
                    }

                    // MARK: - ENABLE BLOCKING TOGGLE

                    // Turns app blocking on or off.
                    Toggle(isOn: $appBlockingEnabled) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Enable App Blocking")
                                .foregroundColor(currentTheme.primaryText)
                                .font(.headline)

                            Text(appBlockingEnabled ? "Blocking mode is currently active." : "Turn this on when you are ready to focus.")
                                .foregroundColor(currentTheme.secondaryText)
                                .font(.subheadline)
                        }
                    }
                    .tint(currentTheme.accent)
                    .padding()
                    .background(currentTheme.cardBackground)
                    .cornerRadius(22)

                    // When the toggle changes, either apply or clear blocking.
                    .onChange(of: appBlockingEnabled) { _, isEnabled in
                        if isEnabled {
                            applyBlocking()
                        } else {
                            clearBlocking()
                        }
                    }

                    // MARK: - STATUS CARD

                    // Shows the user what is currently happening.
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Status")
                            .foregroundColor(currentTheme.primaryText)
                            .font(.headline)

                        Text(statusMessage)
                            .foregroundColor(currentTheme.secondaryText)
                            .font(.body)

                        // Shows how many distractions are selected.
                        if totalSelections > 0 {
                            Text("\(totalSelections) distraction\(totalSelections == 1 ? "" : "s") selected.")
                                .foregroundColor(currentTheme.accent)
                                .font(.footnote)
                                .fontWeight(.semibold)
                        } else {
                            Text("No apps have been selected yet.")
                                .foregroundColor(currentTheme.secondaryText.opacity(0.85))
                                .font(.footnote)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(currentTheme.cardBackground)
                    .cornerRadius(22)

                    // MARK: - PROTOTYPE NOTE

                    // Explains why this feature is presented as a prototype.
                    // This is important for the professor because app blocking requires Apple approval.
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "info.circle")
                                .foregroundColor(currentTheme.accent)

                            Text("Prototype Note")
                                .foregroundColor(currentTheme.primaryText)
                                .font(.headline)
                        }

                        Text("App Blocking is currently kept as a prototype because full device-level app blocking requires Apple’s restricted Family Controls entitlement. Since this is a senior project build, this screen demonstrates the intended user flow: selecting distracting apps, enabling blocking mode, and showing how the feature would work in a production version. In the full version, blocked apps would show a custom blocking screen that reminds the user to stay focused and motivates them to be productive instead of opening distractions.")
                            .foregroundColor(currentTheme.secondaryText)
                            .font(.footnote)
                            .lineSpacing(3)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(currentTheme.cardBackground)
                    .cornerRadius(22)
                }
                .padding()
            }
        }

        // Hides the default back button because this screen uses a custom back button.
        .navigationBarBackButtonHidden(true)

        // Shows Apple's Family Activity Picker when showFamilyActivityPicker is true.
        .familyActivityPicker(
            isPresented: $showFamilyActivityPicker,
            selection: $familyActivitySelection
        )

        // Runs when the screen appears.
        // Updates the status message depending on whether blocking is already on.
        .onAppear {
            if appBlockingEnabled {
                applyBlocking()
            } else if totalSelections > 0 {
                statusMessage = "\(totalSelections) distraction\(totalSelections == 1 ? "" : "s") selected. Turn on App Blocking to activate."
            }
        }

        // Runs whenever the selected apps/categories/websites change.
        .onChange(of: familyActivitySelection) { _, _ in
            handleSelectionChanged()
        }
    }

    // MARK: - SELECTION HANDLING

    // Updates the screen after the user chooses or removes selected distractions.
    func handleSelectionChanged() {

        // If the user selected at least one distraction, update the message.
        if totalSelections > 0 {
            statusMessage = "\(totalSelections) distraction\(totalSelections == 1 ? "" : "s") selected. Turn on App Blocking to activate."

            // If blocking is already enabled, apply blocking to the new selections.
            if appBlockingEnabled {
                applyBlocking()
            }
        } else {

            // If the user has no selections but blocking is on, turn blocking off.
            if appBlockingEnabled {
                appBlockingEnabled = false
                clearBlocking()
            }

            statusMessage = "Choose apps, then turn on App Blocking."
        }
    }

    // MARK: - APPLY BLOCKING

    // Applies shielding/blocking rules to selected apps, categories, and websites.
    func applyBlocking() {

        // The user must select at least one app/category/website before enabling blocking.
        guard totalSelections > 0 else {
            appBlockingEnabled = false
            statusMessage = "Choose at least one app, category, or website before turning on App Blocking."
            return
        }

        // Blocks selected individual apps.
        // If no apps were selected, this is set to nil.
        store.shield.applications = familyActivitySelection.applicationTokens.isEmpty ? nil : familyActivitySelection.applicationTokens

        // Blocks selected app categories.
        // Example: Social, Games, Entertainment, etc.
        store.shield.applicationCategories = familyActivitySelection.categoryTokens.isEmpty ? nil : .specific(familyActivitySelection.categoryTokens)

        // Blocks selected web domains.
        store.shield.webDomains = familyActivitySelection.webDomainTokens.isEmpty ? nil : familyActivitySelection.webDomainTokens

        // Updates the message shown to the user.
        statusMessage = "Blocking mode is active for the selected distractions."
    }

    // MARK: - CLEAR BLOCKING

    // Removes all active blocking/shielding rules.
    func clearBlocking() {

        // Clears blocked apps.
        store.shield.applications = nil

        // Clears blocked app categories.
        store.shield.applicationCategories = nil

        // Clears blocked websites.
        store.shield.webDomains = nil

        // Updates the message depending on whether the user still has selections saved.
        if totalSelections > 0 {
            statusMessage = "\(totalSelections) distraction\(totalSelections == 1 ? "" : "s") selected. App Blocking is currently off."
        } else {
            statusMessage = "App Blocking is off. No apps are currently blocked."
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
