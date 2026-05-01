import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) { }
}

@main
struct SideSketchMacApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var receiverManager: ReceiverManager
    @StateObject private var canvasModel: CanvasModel
    
    init() {
        let canvas = CanvasModel()
        let manager = ReceiverManager(canvasModel: canvas)
        _canvasModel = StateObject(wrappedValue: canvas)
        _receiverManager = StateObject(wrappedValue: manager)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(canvasModel)
                .environmentObject(receiverManager)
        }
        
        MenuBarExtra("SideSketch", systemImage: "pencil.and.scribble") {
            StatusView()
                .environmentObject(receiverManager)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(receiverManager)
        }
    }
}
