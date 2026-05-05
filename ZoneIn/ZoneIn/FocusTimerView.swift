import SwiftUI
import AudioToolbox  // Allows the app to play system sounds or vibrations when the timer ends
import FamilyControls 

// MARK: - FOCUS TIMER
// FocusTimerView is the screen where the user creates and runs a focus session.
// It allows the user to choose a time, start the timer, pause/resume, reset,
// and save completed focus sessions to history.

struct FocusTimerView: View {

    // MARK: - BINDINGS FROM OTHER VIEWS

    // @Binding means this view is receiving data from another view.
    // When this screen changes focusHistory, the change also updates ContentView.
    @Binding var focusHistory: [FocusSession]

    // Stores the selected app theme passed from ContentView.
    @Binding var selectedAppearance: ThemeOption

    // Stores selected apps/categories for future app blocking features.
    // This is passed in so the timer can eventually connect focus sessions with app blocking.
    @Binding var familyActivitySelection: FamilyActivitySelection


    // MARK: - TIMER SETUP STATE

    // These values store what the user selects in the wheel pickers.
    @State private var selectedHours = 0
    @State private var selectedMinutes = 25
    @State private var selectedSeconds = 0


    // MARK: - TIMER RUNNING STATE

    // How many seconds are left in the current session.
    @State private var timeRemaining = 0

    // The original total time selected by the user.
    // This is used to calculate the progress circle.
    @State private var totalTime = 0

    // The actual Timer object that counts down every second.
    @State private var timer: Timer? = nil

    // Tracks whether the timer is currently counting down.
    @State private var isRunning = false

    // Tracks whether the user has started a session.
    @State private var hasStarted = false

    // Tracks whether the session has finished.
    @State private var sessionComplete = false


    // MARK: - THEME

    // Gets the colors for the current selected theme.
    var currentTheme: AppTheme {
        themeColors(for: selectedAppearance)
    }


    // MARK: - BODY

    var body: some View {
        ZStack {

            // Sets the screen background based on the selected theme.
            currentTheme.background.ignoresSafeArea()

            // Shows a different screen depending on the timer state.
            if !hasStarted && !sessionComplete {

                // Before the timer starts, show the time picker setup screen.
                timerSetupView

            } else if hasStarted && !sessionComplete {

                // While the timer is active, show the countdown screen.
                timerRunningView

            } else if sessionComplete {

                // After the timer finishes, show the completion screen.
                sessionCompleteView
            }
        }

        // Stops the timer if the user leaves the screen.
        // This prevents the timer from continuing to run in the background accidentally.
        .onDisappear {
            timer?.invalidate()
        }
    }


    // MARK: - TIMER SETUP VIEW

    // This is the screen shown before the focus session starts.
    var timerSetupView: some View {
        VStack(spacing: 28) {
            Spacer()

            Text("Focus Session")
                .foregroundColor(currentTheme.primaryText)
                .font(.system(size: 30, weight: .semibold, design: .rounded))

            Text("Stay focused. Enter your zone.")
                .foregroundColor(currentTheme.secondaryText)
                .font(.headline)

            // Time picker card.
            VStack(spacing: 12) {
                HStack(spacing: 0) {

                    // Picker for hours.
                    timePickerColumn(title: "Hours", selection: $selectedHours, range: 0..<24, label: "hr")

                    // Picker for minutes.
                    timePickerColumn(title: "Minutes", selection: $selectedMinutes, range: 0..<60, label: "min")

                    // Picker for seconds.
                    timePickerColumn(title: "Seconds", selection: $selectedSeconds, range: 0..<60, label: "sec")
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 10)
            .background(currentTheme.cardBackground)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(currentTheme.secondaryBackground, lineWidth: 1)
            )
            .padding(.horizontal, 20)

            // Starts the timer using the time selected by the user.
            Button(action: {
                startSelectedTimer()
            }) {
                Text("Start Focus Session")
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(currentTheme.accent)
                    .cornerRadius(16)
                    .padding(.horizontal, 30)
            }

            Spacer()
        }
        .padding(.vertical)
    }


    // MARK: - TIME PICKER COLUMN

    // Creates one picker column for hours, minutes, or seconds.
    // This avoids repeating the same picker code three times.
    func timePickerColumn(title: String, selection: Binding<Int>, range: Range<Int>, label: String) -> some View {
        VStack {

            // Wheel picker that lets the user scroll through numbers.
            Picker(title, selection: selection) {
                ForEach(range, id: \.self) { value in
                    Text("\(value)")
                        .foregroundColor(currentTheme.primaryText)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 90, height: 180)
            .clipped()

            // Label under the picker, such as hr, min, or sec.
            Text(label)
                .foregroundColor(currentTheme.secondaryText)
                .font(.subheadline)
        }
    }


    // MARK: - TIMER RUNNING VIEW

    // This is the screen shown while the timer is counting down.
    var timerRunningView: some View {
        VStack(spacing: 35) {
            Spacer()

            Text("Focus Session")
                .foregroundColor(currentTheme.primaryText)
                .font(.system(size: 30, weight: .semibold, design: .rounded))

            Text("Stay focused. Enter your zone.")
                .foregroundColor(currentTheme.secondaryText)
                .font(.headline)

            // Circular countdown display.
            ZStack {

                // Soft glowing background circle.
                Circle()
                    .fill(currentTheme.accent.opacity(0.10))
                    .frame(width: 310, height: 310)
                    .blur(radius: 8)

                // Background ring behind the progress circle.
                Circle()
                    .stroke(currentTheme.secondaryBackground, lineWidth: 18)
                    .frame(width: 290, height: 290)

                // Progress ring.
                // The trim value controls how much of the circle is filled.
                Circle()
                    .trim(from: 0, to: progressValue())
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [currentTheme.accent, Color.cyan]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .frame(width: 290, height: 290)

                    // Rotates the circle so the progress starts at the top instead of the side.
                    .rotationEffect(.degrees(-90))

                    // Animates the progress as timeRemaining changes.
                    .animation(.linear(duration: 1), value: timeRemaining)

                // Inner circle behind the timer text.
                Circle()
                    .fill(currentTheme.secondaryBackground)
                    .frame(width: 230, height: 230)

                VStack(spacing: 8) {

                    // Shows the time remaining in MM:SS or HH:MM:SS format.
                    Text(formatTime(timeRemaining))
                        .foregroundColor(currentTheme.primaryText)
                        .font(.system(size: 52, weight: .bold, design: .rounded))

                    Text("remaining")
                        .foregroundColor(currentTheme.secondaryText)
                        .font(.subheadline)
                }
            }

            // Pause/resume and reset controls.
            HStack(spacing: 28) {

                // Pause button while running.
                // Resume button when paused.
                Button(action: {
                    if isRunning {
                        pauseTimer()
                    } else {
                        resumeTimer()
                    }
                }) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .foregroundColor(currentTheme.primaryText)
                        .font(.title2)
                        .frame(width: 68, height: 68)
                        .background(currentTheme.cardBackground)
                        .clipShape(Circle())
                }

                // Resets the session and returns to the setup screen.
                Button(action: {
                    resetTimer()
                }) {
                    Text("RESET")
                        .foregroundColor(currentTheme.primaryText.opacity(0.85))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(currentTheme.cardBackground)
                        .cornerRadius(12)
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical)
    }


    // MARK: - SESSION COMPLETE VIEW

    // This screen appears after the timer reaches zero.
    var sessionCompleteView: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(currentTheme.accent)
                .font(.system(size: 90))

            Text("Session Complete")
                .foregroundColor(currentTheme.primaryText)
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Text("Great work. You stayed in your zone.")
                .foregroundColor(currentTheme.secondaryText)
                .font(.headline)

            // Resets the screen so the user can start another focus session.
            Button(action: {
                prepareForNewSession()
            }) {
                Text("Start Another Session")
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(currentTheme.accent)
                    .cornerRadius(16)
                    .padding(.horizontal, 30)
            }

            Spacer()
        }
    }


    // MARK: - TIMER LOGIC

    // Converts the selected hours, minutes, and seconds into one total number of seconds.
    func selectedTimeInSeconds() -> Int {
        (selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds
    }

    // Starts the timer using the selected picker values.
    func startSelectedTimer() {
        let chosenTime = selectedTimeInSeconds()

        // Prevents the timer from starting if the user selected 0 seconds.
        if chosenTime <= 0 { return }

        // Saves the selected time.
        totalTime = chosenTime
        timeRemaining = chosenTime

        // Changes the screen from setup mode to running mode.
        hasStarted = true
        sessionComplete = false

        // Begins the countdown.
        startTimer()
    }

    // Creates the timer that counts down every second.
    func startTimer() {

        // Prevents multiple timers from running at the same time.
        if isRunning { return }

        isRunning = true

        // Runs this code once every second.
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in

            // If there is still time left, subtract one second.
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {

                // When the timer reaches zero, complete the session.
                completeSession()
            }
        }
    }

    // Stops the timer but keeps the remaining time.
    func pauseTimer() {
        timer?.invalidate()
        isRunning = false
    }

    // Starts the timer again after it was paused.
    func resumeTimer() {
        startTimer()
    }

    // Stops the session and returns to the setup screen.
    func resetTimer() {
        timer?.invalidate()
        isRunning = false
        timeRemaining = 0
        totalTime = 0
        hasStarted = false
        sessionComplete = false
    }

    // Runs when the timer reaches zero.
    func completeSession() {

        // Stops the timer.
        timer?.invalidate()
        isRunning = false

        // Changes the screen to the completion view.
        hasStarted = false
        sessionComplete = true

        // Makes the phone vibrate to notify the user that the session is complete.
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        // Creates a completed focus session with the duration and completion date.
        let completedSession = FocusSession(
            durationSeconds: totalTime,
            completedAt: Date()
        )

        // Adds the new session to the beginning of the history list.
        focusHistory.insert(completedSession, at: 0)
    }

    // Prepares the screen for another timer session.
    func prepareForNewSession() {
        timeRemaining = 0
        totalTime = 0
        hasStarted = false
        sessionComplete = false
    }

    // Converts seconds into a readable time format.
    // Example: 1500 seconds becomes 25:00.
    func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60

        // If the timer includes hours, show HH:MM:SS.
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {

            // If the timer is under one hour, show MM:SS.
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    // Calculates the percentage of time remaining.
    // This value controls how full the progress circle is.
    func progressValue() -> Double {
        if totalTime == 0 { return 0 }
        return Double(timeRemaining) / Double(totalTime)
    }
}
