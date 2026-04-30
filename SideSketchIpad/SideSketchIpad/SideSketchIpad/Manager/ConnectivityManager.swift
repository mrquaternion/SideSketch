
import Foundation
import Network
import Combine

@MainActor
final class ConnectivityManager: ObservableObject, ConnectivityManaging {

    @Published var connectionStatus: ConnectionStatus = .disconnected

    private var connection: NWConnection?
    private let port: NWEndpoint.Port = 12345
    
    var isConnected: Bool {
        if case .connected = connectionStatus { return true}
        return false
    }

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
                    self.connectionStatus = .connected(ipAddress: ipAddress)
                case .waiting(let error):
                    self.connectionStatus = .waiting(errorLiteral: error.localizedDescription)
                case .failed(let error):
                    self.connectionStatus = .failed(errorLiteral: error.localizedDescription)
                case .cancelled:
                    self.connectionStatus = .disconnected
                default:
                    break
                }
            }
        }

        connection?.start(queue: .global(qos: .userInteractive))
        connectionStatus = .connected(ipAddress: ipAddress)
    }

    func disconnect() {
        connection?.cancel()
        connection = nil
        connectionStatus = .disconnected
    }


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

