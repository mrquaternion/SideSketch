
import Foundation
import Network
import Combine

@MainActor
final class ConnectivityManager: ObservableObject {

    // MARK: - États publiés

    @Published var connectionStatus: String = "Déconnecté"
    @Published var isConnected: Bool = false

    // MARK: - Réseau

    private var connection: NWConnection?
    private let port: NWEndpoint.Port = 12345

    // MARK: - Connexion

    func connect(to ipAddress: String) {
        disconnect()

        let host = NWEndpoint.Host(ipAddress)

        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.noDelay = true

        tcpOptions.connectionTimeout = 5

        let parameters = NWParameters(tls: nil, tcp: tcpOptions)
        connection = NWConnection(host: host, port: port, using: parameters)

        connection?.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch state {
                case .ready:
                    self.isConnected = true
                    self.connectionStatus = "✅ Connecté à \(ipAddress)"
                case .waiting(let error):
                    self.connectionStatus = "⏳ En attente… (\(error.localizedDescription))"
                case .failed(let error):
                    self.isConnected = false
                    self.connectionStatus = "❌ Échec : \(error.localizedDescription)"
                case .cancelled:
                    self.isConnected = false
                    self.connectionStatus = "⏹ Déconnecté"
                default:
                    break
                }
            }
        }

        connection?.start(queue: .global(qos: .userInteractive))
        connectionStatus = "🔄 Connexion à \(ipAddress)…"
    }

    func disconnect() {
        connection?.cancel()
        connection = nil
        isConnected = false
        connectionStatus = "Déconnecté"
    }

    // MARK: - Envoi des paquets

    func send(packet: StylusPacket) {
        guard isConnected, let connection else { return }

        guard var data = try? JSONEncoder().encode(packet) else { return }
        data.append(0x0A)

        connection.send(
            content: data,
            completion: .contentProcessed { error in
                if let error {
                    print("[SideSketch] Erreur envoi : \(error)")
                }
            }
        )
    }
}
