import SwiftUI // Imports Apple's framework for building the app's user interface
import FamilyControls // Allows the app to use Apple's Screen Time tools for app/category selection

// MARK: - Main Screen
// ContentView is the main home screen of ZoneIn.
// This is the first screen users see after onboarding.
struct ContentView: View {

    // MARK: - APP STORAGE
    // @AppStorage saves data even after the app closes.
    // These values are stored locally on the device.
    
    // Tracks whether the user has completed the onboarding screen.
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false // Switches to true once onboarding occurs.
    
    // Stores the user's name from onboarding/profile.
    @AppStorage("userName") private var userName = ""
    
    // Stores whether notifications are turned on.
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    
    // Stores the reminder time as a number.
    // Date itself cannot be stored directly in AppStorage, so it is saved as a time interval.
    @AppStorage("reminderTimeInterval") private var reminderTimeInterval = Date().timeIntervalSince1970 // 1970 is the Unix epoch, the standard starting point computers use for time.
    
    // Stores a message explaining the current notification status.
    @AppStorage("notificationStatusMessage") private var storedNotificationStatusMessage = "Notifications are currently off."
    
    // Stores the selected theme as a raw string value.
    // Example: "Original", "White", or "Midnight Blue"
    @AppStorage("selectedTheme") private var selectedThemeRaw = ThemeOption.original.rawValue
    
    // Stores the profile image as Data.
    @AppStorage("profileImageData") private var profileImageData = Data()
    
    // Stores whether app blocking is turned on.
    @AppStorage("appBlockingEnabled") private var appBlockingEnabled = false

    // MARK: - TEMPORARY SCREEN STATE
    
    // @State stores data that can change while this screen is being used.
    // Unlike @AppStorage, this data does not automatically persist unless saved manually.
    
    // Tracks which quote is currently shown on the home screen.
    @State private var currentQuoteIndex = 0
    
    // Stores previous quote indexes so the user can swipe down to go back.
    @State private var quoteHistory: [Int] = []
    
    // Stores the user's favorite quotes.
    @State private var favoriteQuotes: [FavoriteQuote] = []
    
    // Stores completed focus timer sessions.
    @State private var focusHistory: [FocusSession] = []
    
    // Stores the user's selected apps/categories for future app blocking features.
    @State private var familyActivitySelection = FamilyActivitySelection()
    
    // Controls the vertical animation movement of the quote.
    // quoteOffset controls how far the quote moves up or down on the screen.
    // CGFloat is a number type used for UI measurements in SwiftUI.
    @State private var quoteOffset: CGFloat = 0
    
    // Controls the fade animation of the quote.
    // quoteOpacity controls how visible the quote is.
    // 1 = visible, 0 = not visible.
    @State private var quoteOpacity: Double = 1
    
    // Tracks whether the user has swiped at least once.
    // This is used to hide the "Swipe to explore" text after the first swipe.
    @State private var hasSwipedQuote = false
    
    // Makes sure the app only picks one random starting quote when the screen first loads.
    @State private var hasChosenStartingQuote = false

    // Controls whether the big heart animation appears after double tapping a quote.
    @State private var showDoubleTapHeart = false
    
    // Stores where the user double tapped so the heart appears at that location.
    // CGPoint stores an x and y location.
    @State private var doubleTapHeartLocation: CGPoint = .zero
    
    // MARK: - QUOTES
    // This array stores all motivational quotes used on the home screen.
    let quotes = [
        "Stay disciplined. Stay focused.",
        "Small steps every day lead to big results.",
        "Discomfort is where growth begins.",
        "Success comes from consistency.",
        "Enter your zone now, thank yourself later.",
        "You don't have to feel 100%, but you have to give it 100%.",
        "Discipline is choosing what you want most over what you want now.",
        "Zone in. No distractions.",
        "Focus builds freedom.",
        "Consistency creates results.",
        "Your future is built by what you do today.",
        "The work you avoid is usually the work you need most.",
        "Do not wait for motivation. Build discipline.",
        "One focused hour can change your day.",
        "You are one decision away from getting back on track.",
        "The goal is not perfection. The goal is progress.",
        "Show up even when it is inconvenient.",
        "Your habits are quietly building your future.",
        "Focus now. Freedom later.",
        "Win the next hour.",
        "Stop negotiating with distractions.",
        "You do not need more time. You need more focus.",
        "The version of you that wins is the one that stays consistent.",
        "Do what needs to be done, not what feels easy.",
        "Enter your zone for your future self.",
        "Discipline beats excuses.",
        "Your focus is your advantage.",
        "The work is the shortcut.",
        "Every focused session is a vote for who you want to become.",
        "Stay patient. Stay consistent.",
        "You build confidence by keeping promises to yourself.",
        "Do the hard thing first.",
        "A focused mind is a powerful mind.",
        "The small wins count.",
        "Progress comes from repetition.",
        "If it matters, protect your focus.",
        "Less scrolling. More building.",
        "Your goals need your attention.",
        "Focus is a skill. Train it.",
        "You are closer than you think, but you still have to work.",
        "Start now. Adjust later.",
        "The session you finish today matters.",
        "Do not let comfort control your future.",
        "The grind becomes easier when the goal is clear.",
        "Stay focused when nobody is watching.",
        "You only lose momentum when you stop moving.",
        "One session at a time.",
        "Make discipline your default.",
        "Your attention is valuable. Spend it carefully.",
        "You are building something bigger than today.",
        "Protect your attention like it matters, because it does.",
        "You do not rise to your goals. You fall to your habits.",
        "No one can do the work for you.",
        "The best time to enter your zone is right now.",
        "Small discipline today creates big freedom later.",
        "Keep going even when the progress feels quiet.",
        "Your future self is watching what you choose today.",
        "Focus is how ideas become real.",
        "Do not confuse being busy with being focused.",
        "The only bad session is the one you never start.",
        "You are capable of more than your distractions tell you.",
        "Your goals need action, not excuses.",
        "Be consistent long enough to surprise yourself.",
        "The work is not always fun, but the result is worth it.",
        "You become disciplined by practicing discipline.",
        "Control your focus, control your direction.",
        "Enter your zone before life forces you to.",
        "Your attention decides your outcome.",
        "Finish what you said you would start.",
        "Every minute of focus counts.",
        "Build the life you keep thinking about.",
        "Your focus today is your freedom tomorrow.",
        "Turn pressure into progress.",
        "Stop waiting for the perfect mood.",
        "The next step is enough.",
        "Your discipline is your proof.",
        "Get quiet. Get focused. Get it done.",
        "A focused day beats a distracted week.",
        "Choose progress over comfort.",
        "Your future needs your focus.",
        "Start small, but start serious.",
        "Focused work creates real confidence.",
        "Momentum begins with one decision.",
        "You are not behind. You are rebuilding.",
        "Do not scroll away your potential.",
        "You owe your goals your attention.",
        "Train your mind to stay.",
        "The more focused you become, the more powerful you become.",
        "Discipline is built in private.",
        "One hour of focus can beat ten hours of distraction.",
        "Stay consistent when it gets boring.",
        "Your dreams require your attention.",
        "Put your phone down. Pick your future up.",
        "The best version of you is built through discipline.",
        "Hard work feels better than regret.",
        "You do not need permission to improve.",
        "Your habits are the foundation.",
        "Focus is the difference between wanting and building.",
        "Be proud, but stay hungry.",
        "Your next session matters.",
        "Zone in and let the results speak.",
        "The effort you give today creates tomorrow’s confidence.",
        "Focus until the work is finished.",
        "Consistency is quiet, but powerful.",
        "A distracted mind delays the dream.",
        "The goal is closer when your focus is clear.",
        "Discipline now. Options later.",
        "Stay focused long enough to change your life."
    ]

    // MARK: - COMPUTED PROPERTIES

    // Converts the saved raw theme string back into a ThemeOption.
    // If something goes wrong, it uses the original theme as the default.
    var selectedAppearance: ThemeOption {
        ThemeOption(rawValue: selectedThemeRaw) ?? .original
    }

    // Creates a Binding for the selected theme.
    // This allows other views, like ProfileView or MenuView, to read and update the theme.
    var selectedAppearanceBinding: Binding<ThemeOption> {
        Binding(
            get: { ThemeOption(rawValue: selectedThemeRaw) ?? .original },
            set: { selectedThemeRaw = $0.rawValue }
        )
    }

    // Converts the saved reminder time interval back into a Date.
    // This lets the app use the value with DatePicker and notification scheduling.
    var reminderTimeBinding: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSince1970: reminderTimeInterval) },
            set: { reminderTimeInterval = $0.timeIntervalSince1970 }
        )
    }

    // Gets the colors for the currently selected theme.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }

    // Gets the actual quote text using the current quote index.
    var currentQuote: String {
        quotes[currentQuoteIndex]
    }

    // Checks whether the current quote is already in the user's favorites.
    var isFavorite: Bool {
        favoriteQuotes.contains { $0.text == currentQuote }
    }

    // Text that appears when the user shares a quote.
    var shareText: String {
        """
        "\(currentQuote)"

        Shared from ZoneIn.
        Stay focused. Enter your zone.

        Download ZoneIn: https://zonein.app
        """
    }

    // MARK: - BODY / USER INTERFACE

    var body: some View {
        NavigationStack {
            ZStack {

                // Sets the background color based on the selected theme.
                currentTheme.background.ignoresSafeArea()

                VStack {

                    // MARK: - TOP NAVIGATION BAR

                    HStack {

                        // Opens the profile/settings screen.
                        NavigationLink(
                            destination: ProfileView(
                                favoriteQuotes: $favoriteQuotes,
                                focusHistory: $focusHistory,
                                favoriteCount: favoriteQuotes.count,
                                sessionCount: focusHistory.count,
                                userName: $userName,
                                notificationsEnabled: $notificationsEnabled,
                                reminderTime: reminderTimeBinding,
                                notificationStatusMessage: $storedNotificationStatusMessage,
                                selectedAppearance: selectedAppearanceBinding,
                                profileImageData: $profileImageData
                            )
                        ) {
                            Image(systemName: "person.circle")
                                .foregroundColor(currentTheme.icon)
                                .font(.title2)
                        }

                        Spacer()

                        // Opens the focus timer screen.
                        NavigationLink(
                            destination: FocusTimerView(
                                focusHistory: $focusHistory,
                                selectedAppearance: selectedAppearanceBinding,
                                familyActivitySelection: $familyActivitySelection
                            )
                        ) {
                            Image(systemName: "timer")
                                .foregroundColor(currentTheme.icon)
                                .font(.title2)
                        }
                    }
                    .padding()

                    Spacer()

                    // MARK: - MAIN QUOTE AREA

                    ZStack {
                        VStack(spacing: 20) {

                            // Shows swipe instructions until the user swipes for the first time.
                            if !hasSwipedQuote {
                                Text("Swipe to explore")
                                    .foregroundColor(currentTheme.secondaryText)
                                    .font(.subheadline)
                                    .transition(.opacity)
                            }

                            // Displays the current motivational quote.
                            Text(currentQuote)
                                .foregroundColor(currentTheme.primaryText)
                                .font(.system(size: 30, weight: .medium))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .offset(y: quoteOffset)       // Used for swipe animation.
                                .opacity(quoteOpacity)        // Used for fade animation.
                        }

                        // Shows a large red heart animation when the user double taps a quote.
                        if showDoubleTapHeart {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 90))
                                .position(doubleTapHeartLocation)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Makes the whole quote area tappable/swipeable.
                    .contentShape(Rectangle())

                    // Swipe gesture:
                    // Swipe up = show a new random quote.
                    // Swipe down = go back to the previous quote.
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.height < -50 {
                                    showRandomNewQuote()
                                } else if value.translation.height > 50 {
                                    showPreviousQuote()
                                }
                            }
                    )

                    // Double tap gesture:
                    // Double tapping a quote favorites it and shows a heart animation.
                    .simultaneousGesture(
                        SpatialTapGesture(count: 2)
                            .onEnded { value in
                                doubleTapHeartLocation = value.location
                                doubleTapFavorite()
                            }
                    )

                    Spacer()

                    // MARK: - SHARE AND FAVORITE BUTTONS

                    HStack(spacing: 40) {

                        // Opens the iOS share sheet so users can share the quote.
                        ShareLink(
                            item: shareText,
                            subject: Text("ZoneIn Quote"),
                            message: Text(currentQuote),
                            preview: SharePreview("ZoneIn Quote", image: Image(systemName: "bolt.fill"))
                        ) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(currentTheme.icon)
                                .font(.title2)
                        }

                        // Heart button for adding/removing the current quote from favorites.
                        Button(action: {
                            toggleFavorite()
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : currentTheme.primaryText)
                                .font(.title)
                                .scaleEffect(isFavorite ? 1.08 : 1.0)
                                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isFavorite)
                        }
                    }
                    .padding(.bottom, 30)

                    // MARK: - BOTTOM NAVIGATION BAR

                    HStack {

                        // Opens the menu screen.
                        // The menu contains favorites, focus history, and other app sections.
                        NavigationLink(
                            destination: MenuView(
                                favoriteQuotes: $favoriteQuotes,
                                focusHistory: $focusHistory,
                                selectedAppearance: selectedAppearanceBinding
                            )
                        ) {
                            Image(systemName: "square.grid.2x2")
                                .foregroundColor(currentTheme.icon)
                                .font(.title2)
                        }

                        Spacer()

                        // Opens the app blocking screen.
                        // This connects to Apple's FamilyControls framework.
                        NavigationLink(
                            destination: AppBlockingView(
                                selectedAppearance: selectedAppearanceBinding,
                                familyActivitySelection: $familyActivitySelection,
                                appBlockingEnabled: $appBlockingEnabled
                            )
                        ) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(currentTheme.icon)
                                .font(.title2)
                        }
                    }
                    .padding()
                }
            }

            // Hides the default navigation bar because the app uses custom icons.
            .navigationBarHidden(true)

            // MARK: - SCREEN LOAD ACTIONS

            .onAppear {

                // Loads saved favorites from local storage.
                favoriteQuotes = StorageManager.loadFavorites()

                // Loads saved focus timer history from local storage.
                focusHistory = StorageManager.loadHistory()

                // Chooses a random starting quote once.
                chooseRandomStartingQuote()
            }

            // Saves favorites whenever the favoriteQuotes array changes.
            .onChange(of: favoriteQuotes) { _, newValue in
                StorageManager.saveFavorites(newValue)
            }

            // Saves focus history whenever the focusHistory array changes.
            .onChange(of: focusHistory) { _, newValue in
                StorageManager.saveHistory(newValue)
            }

            // MARK: - ONBOARDING SCREEN

            // Shows onboarding as a full-screen cover if the user has not completed it.
            .fullScreenCover(
                isPresented: Binding(
                    get: { !hasSeenOnboarding },
                    set: { newValue in
                        hasSeenOnboarding = !newValue
                    }
                )
            ) {
                OnboardingView(
                    hasSeenOnboarding: $hasSeenOnboarding,
                    userName: $userName,
                    notificationsEnabled: $notificationsEnabled,
                    reminderTime: reminderTimeBinding,
                    notificationStatusMessage: $storedNotificationStatusMessage,
                    selectedAppearance: selectedAppearanceBinding
                )
            }
        }
    }

    // MARK: - SWIPE DIRECTION

    // Used to tell the quote animation whether the user swiped up or down.
    enum SwipeDirection {
        case up
        case down
    }

    // MARK: - QUOTE FUNCTIONS

    // Picks a random quote when the home screen first opens.
    // It only does this once so the quote does not keep changing every time the view refreshes.
    func chooseRandomStartingQuote() {
        if !hasChosenStartingQuote {
            currentQuoteIndex = Int.random(in: 0..<quotes.count)
            hasChosenStartingQuote = true
        }
    }

    // Picks a random quote, but avoids picking the quote that is already on screen.
    func randomQuoteIndexAvoidingCurrent() -> Int {
        var available = Array(quotes.indices)
        available.removeAll { $0 == currentQuoteIndex }
        return available.randomElement() ?? currentQuoteIndex
    }

    // Shows a new random quote when the user swipes up.
    func showRandomNewQuote() {
        hasSwipedQuote = true

        // Saves the current quote index so the user can go back to it later.
        quoteHistory.append(currentQuoteIndex)

        // Changes to a new random quote with an upward animation.
        animateQuoteChange(to: randomQuoteIndexAvoidingCurrent(), direction: .up)
    }

    // Shows the previous quote when the user swipes down.
    func showPreviousQuote() {
        hasSwipedQuote = true

        // If there is no previous quote, the function stops here.
        guard let previousQuoteIndex = quoteHistory.popLast() else {
            return
        }

        // Changes back to the previous quote with a downward animation.
        animateQuoteChange(to: previousQuoteIndex, direction: .down)
    }

    // Handles the animation when changing quotes.
    func animateQuoteChange(to newIndex: Int, direction: SwipeDirection) {

        // Decides which direction the quote should move off screen.
        let exitOffset: CGFloat = direction == .down ? 70 : -70

        // Decides where the new quote should enter from.
        let enterOffset: CGFloat = direction == .down ? -70 : 70

        // First animation: move the current quote away and fade it out.
        withAnimation(.easeInOut(duration: 0.18)) {
            quoteOffset = exitOffset
            quoteOpacity = 0
        }

        // Waits until the fade-out animation finishes before changing the quote.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {

            // Updates the quote index to the new quote.
            currentQuoteIndex = newIndex

            // Places the new quote slightly off screen before bringing it in.
            quoteOffset = enterOffset

            // Second animation: move the new quote into place and fade it in.
            withAnimation(.easeInOut(duration: 0.24)) {
                quoteOffset = 0
                quoteOpacity = 1
            }
        }
    }

    // MARK: - FAVORITE FUNCTIONS

    // Adds or removes the current quote from favorites.
    func toggleFavorite() {

        // If the quote is already favorited, remove it.
        if let existingIndex = favoriteQuotes.firstIndex(where: { $0.text == currentQuote }) {
            favoriteQuotes.remove(at: existingIndex)
        } else {

            // If the quote is not favorited, add it with the current date.
            favoriteQuotes.append(
                FavoriteQuote(
                    text: currentQuote,
                    dateSaved: Date()
                )
            )
        }
    }

    // Favorites the quote when the user double taps it.
    // Also shows the large heart animation.
    func doubleTapFavorite() {

        // Only adds the quote if it is not already favorited.
        if !isFavorite {
            favoriteQuotes.append(
                FavoriteQuote(
                    text: currentQuote,
                    dateSaved: Date()
                )
            )
        }

        // Shows the heart animation.
        withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) {
            showDoubleTapHeart = true
        }

        // Hides the heart animation after a short delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            withAnimation(.easeOut(duration: 0.25)) {
                showDoubleTapHeart = false
            }
        }
    }
}

// MARK: - PREVIEW

#Preview {
    ContentView()
}
