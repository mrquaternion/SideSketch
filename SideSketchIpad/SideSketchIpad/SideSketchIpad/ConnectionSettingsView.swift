import SwiftUI

struct ConnectionSettingsView: View {
    @ObservedObject var connectivity: ConnectivityManager
    @Binding var macIPAddress: String

    @FocusState private var isIPFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Label("Connexion", systemImage: "network")
                    .font(.headline)

                Spacer()

                Button("Fermer") {
                    dismiss()
                }
                .font(.caption)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Adresse IP du Mac")
                    .font(.subheadline.weight(.medium))

                HStack(spacing: 8) {
                    HStack {
                        Image(systemName: "desktopcomputer")
                            .foregroundStyle(.secondary)

                        TextField("192.168.1.42", text: $macIPAddress)
                            .keyboardType(.decimalPad)
                            .textContentType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($isIPFieldFocused)
                            .font(.body.monospaced())
                            .submitLabel(.done)
                            .onSubmit {
                                attemptConnection()
                            }

                        if !macIPAddress.isEmpty {
                            Button {
                                macIPAddress = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(10)
                    .background(
                        Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 10)
                    )
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("État")
                    .font(.subheadline.weight(.medium))

                HStack(spacing: 8) {
                    Circle()
                        .fill(connectivity.isConnected ? .green : .red)
                        .frame(width: 10, height: 10)

                    Text(connectivity.connectionStatus.description)
                        .font(.caption)
                        .foregroundStyle(statusColor)
                }
            }

            HStack(spacing: 12) {
                if connectivity.isConnected {
                    Button(role: .destructive) {
                        connectivity.disconnect()
                    } label: {
                        Label("Déconnecter", systemImage: "xmark.circle.fill")
                    }
                } else {
                    Button {
                        isIPFieldFocused = false
                        attemptConnection()
                    } label: {
                        Label("Connecter", systemImage: "arrow.right.circle.fill")
                    }
                    .disabled(macIPAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Button {
                    macIPAddress = ""
                } label: {
                    Label("Effacer", systemImage: "trash")
                }
                .disabled(macIPAddress.isEmpty)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Aide rapide")
                    .font(.subheadline.weight(.medium))

                Text("""
1. Ouvrez l’app SideSketch sur votre Mac
2. Noter l’adresse IP affichée
3. Entrez-la ici puis touchez Connecter
""")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
            }
        }
        .padding(16)
        .onTapGesture {
            isIPFieldFocused = false
        }
    }

    private var statusColor: Color {
        if connectivity.isConnected { return .green }
        if connectivity.connectionStatus.description.contains("X") { return .red }
        if connectivity.connectionStatus.description.contains("Time") { return .orange }
        return .secondary
    }

    private func attemptConnection() {
        let trimmedIP = macIPAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedIP.isEmpty else { return }
        connectivity.connect(to: trimmedIP)
    }
}

#Preview {
    ConnectionSettingsView(
        connectivity: ConnectivityManager(),
        macIPAddress: .constant("192.168.1.42")
    )
}
