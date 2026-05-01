
import SwiftUI
import AppKit

struct StatusView: View {

    @EnvironmentObject var manager: ReceiverManager
    @State private var hasAccessibility: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                Image(systemName: "pencil.and.scribble")
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text("SideSketch")
                    .font(.headline)

                Spacer()

                Button {
                    NSApp.terminate(nil)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Quitter")
            }

            Divider()

            if !hasAccessibility {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Permission Accessibilité requise")
                            .font(.callout.bold())

                        Text("Sans elle, le curseur ne bougera pas.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button("Ouvrir Réglages") {
                        openAccessibilitySettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                .padding(10)
                .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            } else {
                Label("Accessibilité accordée", systemImage: "checkmark.shield.fill")
                    .foregroundStyle(.green)
                    .font(.callout)
            }

            Divider()

            Label {
                Text(manager.statusMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } icon: {
                Circle()
                    .fill(manager.isListening ? .green : .red)
                    .frame(width: 10, height: 10)
            }

            if let clientIP = manager.connectedClientAddress {
                HStack {
                    Image(systemName: "ipad")
                    Text("iPad : \(clientIP)")
                        .font(.callout.monospaced())
                }
                .foregroundStyle(.teal)
            }

            if let localIP = getLocalIPAddress() {
                HStack(alignment: .top) {
                    Image(systemName: "desktopcomputer")
                    Text("IP de ce Mac : \(localIP)")
                        .font(.callout.monospaced())
                        .textSelection(.enabled)
                }
            }

            Divider()

            HStack {
                Button {
                    manager.startListening()
                } label: {
                    Label("Démarrer", systemImage: "play.fill")
                }
                .disabled(manager.isListening)

                Button {
                    manager.stopListening()
                } label: {
                    Label("Arrêter", systemImage: "stop.fill")
                }
                .disabled(!manager.isListening)
            }

            HStack {
                Button {
                    checkPermission()
                } label: {
                    Label("Vérifier permission", systemImage: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.link)

                Spacer()

                Button("Quitter") {
                    NSApp.terminate(nil)
                }
            }
        }
        .padding(16)
        .frame(width: 360)
        .onAppear {
            checkPermission()

            if !manager.isListening {
                manager.startListening()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            checkPermission()
        }
    }


    private func checkPermission() {
        let options = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue(): false
        ] as CFDictionary

        hasAccessibility = AXIsProcessTrustedWithOptions(options)
    }

    private func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }


    private func openSettingsWindow() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }


    private func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return nil
        }

        defer { freeifaddrs(ifaddr) }

        var ptr = firstAddr
        while true {
            let interface = ptr.pointee

            if interface.ifa_addr.pointee.sa_family == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)

                if name == "en0" || name == "en1" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))

                    getnameinfo(
                        interface.ifa_addr,
                        socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        0,
                        NI_NUMERICHOST
                    )

                    address = String(cString: hostname)
                    break
                }
            }

            guard let next = interface.ifa_next else { break }
            ptr = next
        }

        return address
    }
}

#Preview {
    StatusView()
        .environmentObject(ReceiverManager(canvasModel: CanvasModel()))
}
