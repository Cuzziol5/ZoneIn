// Imports Apple's Foundation framework, which provides basic tools for saving data, encoding and decoding JSON, working with dates, and using UserDefaults.
import Foundation

// MARK: - STORAGE

// StorageManager is responsible for saving and loading app data.
// In ZoneIn, it saves favorite quotes and completed focus sessions.
struct StorageManager {

    // MARK: - USERDEFAULTS KEYS

    // These keys are the names used to store data inside UserDefaults.
    // Think of them like labels for saved data.
    static let favoritesKey = "saved_favorite_quotes"
    static let historyKey = "saved_focus_history"


    // MARK: - FAVORITES STORAGE

    // Saves the user's favorite quotes.
    static func saveFavorites(_ favorites: [FavoriteQuote]) {
        save(favorites, forKey: favoritesKey)
    }

    // Loads the user's favorite quotes.
    // If nothing has been saved yet, it returns an empty array.
    static func loadFavorites() -> [FavoriteQuote] {
        load([FavoriteQuote].self, forKey: favoritesKey) ?? []
    }


    // MARK: - FOCUS HISTORY STORAGE

    // Saves the user's completed focus sessions.
    static func saveHistory(_ history: [FocusSession]) {
        save(history, forKey: historyKey)
    }

    // Loads the user's completed focus sessions.
    // If nothing has been saved yet, it returns an empty array.
    static func loadHistory() -> [FocusSession] {
        load([FocusSession].self, forKey: historyKey) ?? []
    }


    // MARK: - GENERIC SAVE FUNCTION

    // This function can save any Codable value.
    // Codable means the data can be converted into a format that can be stored.
    static func save<T: Codable>(_ value: T, forKey key: String) {
        do {
            // Converts the Swift object into JSON data.
            // JSONEncoder converts your Swift data into JSON so it can be saved.
            let data = try JSONEncoder().encode(value)

            // Saves the JSON data into UserDefaults using the provided key.
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            // Prints an error message if saving fails.
            print("Failed to save \(key): \(error.localizedDescription)")
        }
    }


    // MARK: - GENERIC LOAD FUNCTION

    // This function can load any Codable value.
    // It uses the type passed in to know what kind of data to decode.
    static func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {

        // Tries to get saved data from UserDefaults.
        // If no data exists for that key, it returns nil.
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        do {
            // Converts the saved JSON data back into a Swift object.
            // JSONDecoder converts the saved JSON back into Swift data when the app opens again.
            return try JSONDecoder().decode(type, from: data)
        } catch {
            // Prints an error message if loading fails.
            print("Failed to load \(key): \(error.localizedDescription)")
            return nil
        }
    }
}
