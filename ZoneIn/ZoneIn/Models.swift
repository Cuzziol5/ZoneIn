import Foundation

// MARK: - MODELS
// Models define the structure of the data used in the app.
// ZoneIn uses these models to store favorite quotes and completed focus sessions.


// MARK: - FAVORITE QUOTE MODEL

// FavoriteQuote represents one quote that the user saved as a favorite.
struct FavoriteQuote: Identifiable, Codable, Hashable {

    // Unique ID for each favorite quote.
    // Identifiable lets SwiftUI use this model in lists.
    let id: UUID

    // The actual quote text.
    let text: String

    // The date and time when the quote was saved.
    let dateSaved: Date

    // Custom initializer.
    // If no ID is provided, a new random UUID is created automatically.
    init(id: UUID = UUID(), text: String, dateSaved: Date) {
        self.id = id
        self.text = text
        self.dateSaved = dateSaved
    }
}


// MARK: - FOCUS SESSION MODEL

// FocusSession represents one completed timer session.
struct FocusSession: Identifiable, Codable, Hashable {

    // Unique ID for each focus session.
    // This helps SwiftUI display each session separately in lists.
    let id: UUID

    // The length of the completed focus session in seconds.
    let durationSeconds: Int

    // The date and time when the focus session was completed.
    let completedAt: Date

    // Custom initializer.
    // If no ID is provided, a new random UUID is created automatically.
    init(id: UUID = UUID(), durationSeconds: Int, completedAt: Date) {
        self.id = id
        self.durationSeconds = durationSeconds
        self.completedAt = completedAt
    }
}
