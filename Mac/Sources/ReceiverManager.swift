//
//  ReceiverManager.swift
//  
//
//  Created by Yamir A. Poldo Silva on 2026-02-20.
//

import MultipeerConnectivity
import SwiftUI

class ReceiverManager: NSObject, ObservableObject, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    private let serviceBrowser: MCNearbyServiceBrowser
    private let session: MCSession
    private let peerID = MCPeerID(displayName: Host.current().localizedName ?? "Mac")
    private let cursorController = CursorController()
    
    @Published var connectionStatus = "En attente..."
    
    override init() {
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: kServiceType)
        
        super.init()
        
        self.session.delegate = self
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    // MARK: - Browser Delegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Inviter automatiquement tout pair trouvé (pour la démo)
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        DispatchQueue.main.async { self.connectionStatus = "Invitation envoyée à \(peerID.displayName)" }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async { self.connectionStatus = "Perdu: \(peerID.displayName)" }
    }

    // MARK: - Session Delegate
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Décodage et action sur le thread principal ou dédié
        do {
            let packet = try JSONDecoder().decode(StylusPacket.self, from: data)
            DispatchQueue.main.async {
                self.cursorController.processPacket(packet)
            }
        } catch {
            print("Erreur décodage: \(error)")
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected: self.connectionStatus = "Connecté: \(peerID.displayName)"
            case .connecting: self.connectionStatus = "Connexion..."
            case .notConnected: self.connectionStatus = "Déconnecté"
            @unknown default: break
            }
        }
    }
    
    // Stubs
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
