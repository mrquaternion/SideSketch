//
//  ConnectivityManager.swift
//  SideSketchIpad
//
//  Created by Yamir A. Poldo Silva on 2026-02-20.
//


import Foundation
import MultipeerConnectivity
import SwiftUI
import Combine

class ConnectivityManager: NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let session: MCSession
    private static let myPeerID: MCPeerID = {
          let defaults = UserDefaults.standard
          if let data = defaults.data(forKey: "peerID"),
             let peer = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data) {
              return peer
          }
          let peer = MCPeerID(displayName: UIDevice.current.name)
          let data = try? NSKeyedArchiver.archivedData(withRootObject: peer, requiringSecureCoding: true)
          defaults.set(data, forKey: "peerID")
          return peer
      }()
    
    
    
    @Published var isConnected = false
    @Published var isReadyToSend = false
    
    override init() {
        self.session = MCSession(peer: Self.myPeerID, securityIdentity: nil, encryptionPreference: .none)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: Self.myPeerID, discoveryInfo: nil, serviceType: kServiceType)
        
        super.init()
        
        self.session.delegate = self
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    func send(packet: StylusPacket) {
        guard isReadyToSend, !session.connectedPeers.isEmpty else {
            print("Send ignoré: pas encore prêt ou aucun peer")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(packet)
            try session.send(data, toPeers: session.connectedPeers, with: .unreliable)
        } catch {
            print("Erreur d'envoi: \(error)")
        }
    }
    
    // MARK: - MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Invitation reçue de \(peerID.displayName)")
        invitationHandler(true, self.session)
    }
    
    // MARK: - MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.isConnected = (state == .connected)
            
            if state == .connected {
                self.serviceAdvertiser.stopAdvertisingPeer()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isReadyToSend = true
                }
            } else {
                self.isReadyToSend = false
                self.serviceAdvertiser.startAdvertisingPeer()
            }
        }
    }
    
    // MARK: - Stubs
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
