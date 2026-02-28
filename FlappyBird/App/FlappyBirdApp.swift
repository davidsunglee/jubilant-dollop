import SwiftUI

@main
struct FlappyBirdApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .defaultSize(width: 800, height: 600)
        #endif
    }
}
