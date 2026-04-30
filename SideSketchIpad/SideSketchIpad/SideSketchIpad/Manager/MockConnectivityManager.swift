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
    @Published var isConnected: Bool
    
    init(shouldBeConnected: Bool) {
        self.isConnected = shouldBeConnected
        self.connectionStatus = shouldBeConnected ? .connected(ipAddress: "192.168.1.42") : .disconnected
    }
    
    func connect(to ipAddress: String) {
        connectionStatus = .connected(ipAddress: ipAddress)
        isConnected = true
    }
    
    func disconnect() {
        connectionStatus = .disconnected
        isConnected = false
    }
    
    func send(packet: StylusPacket) { }
}
