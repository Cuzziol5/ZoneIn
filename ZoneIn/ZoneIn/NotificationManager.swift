import Foundation
import UserNotifications

// MARK: - NOTIFICATIONS

// NotificationManager controls all notification related logic for ZoneIn.
// This includes asking for notification permission, checking notification status,
// scheduling daily reminders, and canceling reminders.
struct NotificationManager {

    // This is the base identifier used for ZoneIn reminder notifications.
    // Identifiers help the app find and remove old scheduled notifications.
    static let reminderIdentifier = "daily_zonein_reminder"

    // These are motivational quotes used inside the daily reminder notifications.
    // Each scheduled reminder randomly picks one of these quotes.
    static let dailyNotificationQuotes = [
        "Stay disciplined. Stay focused.",
        "Small steps every day lead to big results.",
        "Discomfort is where growth begins.",
        "Success comes from consistency.",
        "Enter your zone now, thank yourself later.",
        "Zone in. No distractions.",
        "Focus builds freedom.",
        "Consistency creates results.",
        "Your future is built by what you do today.",
        "Do not wait for motivation. Build discipline.",
        "One focused hour can change your day.",
        "Focus now. Freedom later.",
        "Win the next hour.",
        "Stop negotiating with distractions.",
        "Discipline beats excuses.",
        "Your focus is your advantage.",
        "Do the hard thing first.",
        "Less scrolling. More building.",
        "Focus is a skill. Train it.",
        "The only bad session is the one you never start.",
        "Control your focus, control your direction.",
        "Every minute of focus counts.",
        "Your focus today is your freedom tomorrow.",
        "Choose progress over comfort.",
        "Put your phone down. Pick your future up.",
        "Hard work feels better than regret.",
        "Discipline now. Options later.",
        "Stay focused long enough to change your life."
    ]


    // MARK: - REQUEST NOTIFICATION PERMISSION

    // This function asks the user for permission to send notifications.
    // The completion returns true if permission was granted and false if it was denied.
    static func requestPermission(completion: @escaping (Bool) -> Void) {

        // Gets the current notification center for the app.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in

            // If there is an error while asking for permission, print it in Xcode.
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }

            // Sends the permission result back on the main thread.
            // UI updates should happen on the main thread.
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }


    // MARK: - CHECK NOTIFICATION STATUS

    // This function checks the user's current notification permission status.
    // Example statuses include authorized, denied, notDetermined, or provisional.
    static func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {

        // Gets the current notification settings from iOS.
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            // Returns the authorization status on the main thread.
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }


    // MARK: - SCHEDULE DAILY REMINDER

    // This function schedules daily reminder notifications at the selected time.
    // Instead of using one repeating notification, it schedules reminders for the next 30 days.
    static func scheduleDailyReminder(at date: Date, completion: ((Error?) -> Void)? = nil) {

        // Gets the app's notification center.
        let center = UNUserNotificationCenter.current()

        // Removes any old ZoneIn reminders first.
        // This prevents duplicate reminders from stacking up if the user changes the time.
        let identifiersToRemove = [reminderIdentifier] + (0..<30).map { "\(reminderIdentifier)_\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)

        // Gets only the hour and minute from the user's selected reminder time.
        let calendar = Calendar.current
        let selectedComponents = calendar.dateComponents([.hour, .minute], from: date)

        // Stores any error that happens while scheduling notifications.
        var scheduledError: Error?

        // Creates one notification for each of the next 30 days.
        for dayOffset in 0..<30 {

            // Creates a target date by adding dayOffset days to today's date.
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else {
                continue
            }

            // Gets the year, month, and day for the target date.
            var components = calendar.dateComponents([.year, .month, .day], from: targetDate)

            // Adds the selected hour and minute to that target date.
            components.hour = selectedComponents.hour
            components.minute = selectedComponents.minute

            // Converts the date components into a real Date.
            guard let reminderDate = calendar.date(from: components) else {
                continue
            }

            // If today's reminder time already passed, skip today's notification.
            if dayOffset == 0 && reminderDate <= Date() {
                continue
            }

            // Creates the notification content.
            let content = UNMutableNotificationContent()
            content.title = "ZoneIn Reminder"
            content.body = dailyNotificationQuotes.randomElement() ?? "Stay focused. Enter your zone."
            content.sound = .default

            // Creates a calendar trigger for the exact day and time.
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            // Creates a notification request with a unique identifier.
            let request = UNNotificationRequest(
                identifier: "\(reminderIdentifier)_\(dayOffset)",
                content: content,
                trigger: trigger
            )

            // Adds the notification request to iOS.
            center.add(request) { error in
                if let error = error {
                    scheduledError = error
                    print("Notification scheduling error: \(error.localizedDescription)")
                }
            }
        }

        // Calls the completion handler after scheduling is requested.
        DispatchQueue.main.async {
            completion?(scheduledError)
        }
    }


    // MARK: - CANCEL DAILY REMINDER

    // This function cancels all scheduled ZoneIn reminder notifications.
    static func cancelDailyReminder() {

        // Builds the list of notification identifiers that should be removed.
        let identifiersToRemove = [reminderIdentifier] + (0..<30).map { "\(reminderIdentifier)_\($0)" }

        // Removes all pending ZoneIn reminder notifications from iOS.
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
    }
}
