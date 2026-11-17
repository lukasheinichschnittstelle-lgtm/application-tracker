import SwiftUI
import TrackerCore

@main
struct ApplicationTrackerApp: App {
    @State private var store = Store()

    var body: some Scene {
        Window("Application Tracker", id: "main") {
            TrackerView(store: store)
                .frame(minWidth: 640, minHeight: 520)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Show Data in Finder") { store.showInFinder() }
            }
        }
    }
}
