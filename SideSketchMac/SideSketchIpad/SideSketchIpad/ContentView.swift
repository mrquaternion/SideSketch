// ContentView.swift
// Projet : SideSketchiPad
//
// Rôle : Interface utilisateur principale de l'iPad.
//        - Champ de saisie de l'IP du Mac
//        - Boutons de connexion/déconnexion
//        - Zone de capture tactile (TouchCaptureView)
//        - Indicateur de statut
//
// 🔒 Concurrence Swift 6 :
//   - Toutes les interactions avec ConnectivityManager (qui est @MainActor)
//     se font naturellement sur le MainActor car ContentView est une View SwiftUI
//     exécutée sur le MainActor.

import SwiftUI

struct ContentView: View {

    // MARK: - State

    @StateObject private var connectivity = ConnectivityManager()

    @AppStorage("mac_ip_address") private var macIPAddress: String = ""

    @FocusState private var isIPFieldFocused: Bool

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: Barre de connexion
                connectionBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.regularMaterial)

                Divider()

                // MARK: Zone de dessin
                drawingArea

            }
            .navigationTitle("SideSketch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    statusIndicator
                }
            }
        }
        .onTapGesture {
            isIPFieldFocused = false
        }
    }

    // MARK: - Sous-vues
    private var connectionBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                HStack {
                    Image(systemName: "network")
                        .foregroundStyle(.secondary)
                    TextField("IP du Mac (ex: 192.168.1.42)", text: $macIPAddress)
                        .keyboardType(.decimalPad)
                        .textContentType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isIPFieldFocused)
                        .font(.body.monospaced())
                        .submitLabel(.done)
                        .onSubmit { attemptConnection() }

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
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))

                if connectivity.isConnected {
                    Button(role: .destructive) {
                        connectivity.disconnect()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                    }
                    .transition(.scale)
                } else {
                    Button {
                        isIPFieldFocused = false
                        attemptConnection()
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                    .disabled(macIPAddress.isEmpty)
                }
            }

            Text(connectivity.connectionStatus)
                .font(.caption)
                .foregroundStyle(statusColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.easeInOut, value: connectivity.connectionStatus)
        }
    }

    private var drawingArea: some View {
        ZStack {
            if connectivity.isConnected {
                TouchCaptureView(connectivityManager: connectivity)
                    .padding(12)
                    .overlay(alignment: .topLeading) {

                        Label("Zone active", systemImage: "pencil.tip")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .padding(8)
                    }
            } else {
                disconnectedPlaceholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: connectivity.isConnected)
    }

    private var statusIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(connectivity.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
                .animation(.easeInOut, value: connectivity.isConnected)
            Text(connectivity.isConnected ? "Connecté" : "Déconnecté")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var disconnectedPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "desktopcomputer.and.arrow.down")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)

            VStack(spacing: 8) {
                Text("Connectez-vous à votre Mac")
                    .font(.title3.bold())
                    .foregroundStyle(.primary)

                Text("1. Lancez SideSketchMac sur votre Mac\n2. Notez l'IP affichée dans l'app Mac\n3. Saisissez-la ci-dessus et appuyez sur ->")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(40)
    }

    // MARK: - Helpers

    private var statusColor: Color {
        if connectivity.isConnected { return .green }
        if connectivity.connectionStatus.contains("X") { return .red }
        if connectivity.connectionStatus.contains("Time") { return .orange }
        return .secondary
    }

    private func attemptConnection() {
        let trimmedIP = macIPAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedIP.isEmpty else { return }
        connectivity.connect(to: trimmedIP)
    }
}

#Preview {
    ContentView()
}
