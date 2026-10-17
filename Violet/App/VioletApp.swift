import SwiftUI

@main
struct VioletApp: App {
    init() {
        Appearance.configure()
        Storage.prepare()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
                .tint(Theme.accent)
        }
    }
}
