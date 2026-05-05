import SwiftUI

// MARK: - APP ENTRY POINT

// @main tells Swift that this is where the app starts running.
// Every SwiftUI app needs one main App struct.
@main
struct ZoneInApp: App {

    // The body defines what scene or window the app should open.
    var body: some Scene {

        // WindowGroup creates the main app window.
        // On iPhone, this is the main screen users interact with.
        WindowGroup {

            // ContentView is the first screen that loads when ZoneIn opens.
            ContentView()
        }
    }
}
