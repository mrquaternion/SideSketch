import SwiftUI
import AppKit

@main
struct SideSketchMacApp: App {

    @StateObject private var receiverManager: ReceiverManager = {
        let cursorCtrl = CursorController()
        return ReceiverManager(cursorController: cursorCtrl)
    }()

    var body: some Scene {
        MenuBarExtra("SideSketch", systemImage: "pencil.and.scribble") {
            StatusView()
                .environmentObject(receiverManager)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(receiverManager)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
