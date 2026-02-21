//
//  StylusPacket.swift
//  SideSketchMac
//
//  Created by Yamir A. Poldo Silva on 2026-02-20.
//


import Foundation
import CoreGraphics

// Identifiant du service Bonjour
let kServiceType = "test"

// Structure des données envoyées
struct StylusPacket: Codable {
    let x: CGFloat        // Normalisé 0.0 à 1.0
    let y: CGFloat        // Normalisé 0.0 à 1.0
    let pressure: CGFloat // 0.0 à 1.0 (ou plus selon le stylet)
    let isActive: Bool    // true = stylet touche l'écran (Mouse Down)
}
