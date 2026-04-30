//
//  MockConnectivityManager.swift
//  SideSketchIpad
//
//  Created by Mathias La Rochelle on 2026-04-30.
//

import Combine

@MainActor
final class MockConnectivityManager: ConnectivityManaging {
    @Published var connectionStatus: ConnectionStatus
    
    var isConnected: Bool {
        if case .connected = connectionStatus { return true}
        return false
    }
    
    init(shouldBeConnected: Bool) {
        self.connectionStatus = shouldBeConnected ? .connected(ipAddress: "192.168.1.42") : .disconnected
    }
    
    func connect(to ipAddress: String) {
        connectionStatus = .connected(ipAddress: ipAddress)
    }
    
    func disconnect() {
        connectionStatus = .disconnected
    }
    
    func send(packet: StylusPacket) { }
}
