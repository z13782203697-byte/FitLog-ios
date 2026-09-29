import SwiftUI
import SwiftData

@main
struct FitLogIOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: WorkoutRecord.self)
    }
}
