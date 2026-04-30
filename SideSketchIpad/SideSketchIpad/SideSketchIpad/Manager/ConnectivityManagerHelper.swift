//
//  ConnectivityManagerHelper.swift
//  SideSketchIpad
//
//  Created by Mathias La Rochelle on 2026-04-30.
//

import Foundation

protocol ConnectivityManaging: ObservableObject {
    var connectionStatus: ConnectionStatus { get }
    var isConnected: Bool { get }
    
    func connect(to ipAddress: String)
    func disconnect()
    func send(packet: StylusPacket)
}

enum ConnectionStatus {
    case connected(ipAddress: String)
    case disconnected
    case waiting(errorLiteral: String)
    case failed(errorLiteral: String)
    
    var displayName: String {
        switch self {
        case .connected(_): return "Connecté"
        case .disconnected: return "Déconnecté"
        case .waiting(_): return "En attente"
        case .failed(_): return "Échec"
        }
    }
    
    var description: String {
        switch self {
        case .connected(let ipAddress):
            return "\(displayName) à \(ipAddress)"
        case .disconnected:
            return displayName
        case .waiting(let error), .failed(let error):
            return "\(displayName) : \(error)"
        }
    }
}
