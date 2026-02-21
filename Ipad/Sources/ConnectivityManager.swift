//
//  ConnectivityManager.swift
//  
//
//  Created by Yamir A. Poldo Silva on 2026-02-20.
//

import MultipeerConnectivity
import SwiftUI

class ConnectivityManager: NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let session: MCSession
    private let peerID = MCPeerID(displayName: UIDevice.current.name)
    
    @Published var isConnected = false
    
    override init() {
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: kServiceType)
        
        super.init()
        
        self.session.delegate = self
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    func send(packet: StylusPacket) {
        guard !session.connectedPeers.isEmpty else { return }
        
        do {
            let data = try JSONEncoder().encode(packet)
            // .unreliable est CRUCIAL pour la performance temps réel (UDP-like)
            try session.send(data, toPeers: session.connectedPeers, with: .unreliable)
        } catch {
            print("Erreur d'envoi: \(error)")
        }
    }
    
    // MARK: - MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Accepter automatiquement toute connexion (pour la démo)
        invitationHandler(true, self.session)
    }
    
    // MARK: - MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.isConnected = (state == .connected)
        }
    }
    
    // Stubs obligatoires pour le protocole
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
