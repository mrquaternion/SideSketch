import SwiftUI
import AppKit

struct SettingsView: View {
    @EnvironmentObject var manager: ReceiverManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Réglages SideSketch")
                .font(.title2.bold())

            Text("Préférences de l'application")
                .foregroundStyle(.secondary)

            Divider()

            HStack {
                Text("État du serveur")
                Spacer()
                Label(
                    manager.isListening ? "Actif" : "Inactif",
                    systemImage: manager.isListening ? "checkmark.circle.fill" : "xmark.circle.fill"
                )
                .foregroundStyle(manager.isListening ? .green : .red)
            }

            if let clientIP = manager.connectedClientAddress {
                HStack {
                    Text("Client connecté")
                    Spacer()
                    Text(clientIP)
                        .font(.body.monospaced())
                }
            }

            HStack(spacing: 12) {
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

            Button("Ouvrir Réglages Accessibilité macOS") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }

            Spacer()
        }
        .padding()
        .frame(width: 420, height: 260)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ReceiverManager(cursorController: CursorController()))
}
