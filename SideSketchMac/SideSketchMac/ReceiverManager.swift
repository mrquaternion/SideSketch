
import Foundation
import Network
import Combine

@MainActor
final class ReceiverManager: ObservableObject {

    @Published var statusMessage: String = "En attente de démarrage…"
    @Published var isListening: Bool = false
    @Published var connectedClientAddress: String? = nil

    private let cursorController: CursorController
    private var listener: NWListener?
    private var activeConnection: NWConnection?
    private let port: NWEndpoint.Port = 12345

    private var receiveBuffer: Data = Data()

    init(cursorController: CursorController) {
        self.cursorController = cursorController
    }

    func startListening() {
        stopListening()

        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.noDelay = true

        let parameters = NWParameters(tls: nil, tcp: tcpOptions)
        parameters.allowLocalEndpointReuse = true

        do {
            listener = try NWListener(using: parameters, on: port)
        } catch {
            statusMessage = "Erreur création listener : \(error.localizedDescription)"
            return
        }

        listener?.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch state {
                case .ready:
                    self.statusMessage = "Serveur actif sur le port \(self.port)"
                    self.isListening = true
                    print("Serveur prêt à recevoir des connexions.")
                case .failed(let error):
                    self.statusMessage = "Erreur listener : \(error.localizedDescription)"
                    self.isListening = false
                case .cancelled:
                    self.statusMessage = "Serveur arrêté."
                    self.isListening = false
                default:
                    break
                }
            }
        }

        listener?.newConnectionHandler = { [weak self] connection in
            Task { @MainActor [weak self] in
                self?.handleNewConnection(connection)
            }
        }

        listener?.start(queue: .global(qos: .userInitiated))
        statusMessage = "Démarrage du serveur…"
        print("Tentative de démarrage du serveur sur le port 12345...")
    }

    func stopListening() {
        activeConnection?.cancel()
        activeConnection = nil
        listener?.cancel()
        listener = nil
        isListening = false
        connectedClientAddress = nil
        receiveBuffer = Data()
    }

    private func handleNewConnection(_ connection: NWConnection) {
        activeConnection?.cancel()
        activeConnection = connection
        receiveBuffer = Data()

        if case .hostPort(let host, _) = connection.endpoint {
            connectedClientAddress = "\(host)"
            statusMessage = "iPad connecté : \(host)"
            print("Client connecté : \(host)")
        }

        connection.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch state {
                case .ready:
                    print("Connexion établie et prête pour les données.")
                    self.receiveNextChunk(on: connection)
                case .failed(let error):
                    self.statusMessage = "Connexion perdue : \(error.localizedDescription)"
                    self.connectedClientAddress = nil
                    self.activeConnection = nil
                    self.receiveBuffer = Data()
                case .cancelled:
                    self.connectedClientAddress = nil
                    self.receiveBuffer = Data()
                    if self.isListening {
                        self.statusMessage = "Serveur actif — en attente d'un iPad…"
                    }
                default:
                    break
                }
            }
        }

        connection.start(queue: .global(qos: .userInteractive))
    }

    private func receiveNextChunk(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isComplete, error in

            Task { @MainActor [weak self] in
                guard let self else { return }

                if let error {
                    if case .posix(let code) = error, code == .ENOTCONN { return }
                    print("Erreur réception : \(error.localizedDescription)")
                    return
                }

                if let data, !data.isEmpty {
                    self.receiveBuffer.append(data)
                    self.processBuffer()
                }

                if !isComplete {
                    self.receiveNextChunk(on: connection)
                } else {
                    print("La connexion a été fermée par le client (isComplete).")
                }
            }
        }
    }

    private func processBuffer() {
        let newline = UInt8(0x0A)

        while let newlineIndex = receiveBuffer.firstIndex(of: newline) {
            let packetData = receiveBuffer[receiveBuffer.startIndex..<newlineIndex]

            receiveBuffer = receiveBuffer[(newlineIndex + 1)...]

            if !packetData.isEmpty,
               let packet = try? JSONDecoder().decode(StylusPacket.self, from: packetData) {
                cursorController.apply(packet: packet)
            }
        }
    }
}
