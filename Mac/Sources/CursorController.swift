//
//  CursorController.swift
//  
//
//  Created by Yamir A. Poldo Silva on 2026-02-20.
//

import Cocoa
import CoreGraphics

class CursorController {
    
    // Récupération de l'écran principal
    private var screenFrame: CGRect {
        return NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1920, height: 1080)
    }
    
    func processPacket(_ packet: StylusPacket) {
        // 1. Dénormalisation : Convertir 0.0-1.0 vers Résolution écran (ex: 2560x1600)
        // Note: CoreGraphics utilise l'origine en haut à gauche pour les événements,
        // alors que NSScreen peut avoir l'origine en bas à gauche.
        // CGEvent utilise des coordonnées globales d'affichage.
        
        let targetX = packet.x * screenFrame.width + screenFrame.origin.x
        let targetY = packet.y * screenFrame.height + screenFrame.origin.y // L'iPad envoie Y=0 (haut), CGEvent attend Y=0 (haut) -> Pas d'inversion nécessaire si orientation standard.
        
        let point = CGPoint(x: targetX, y: targetY)
        
        // 2. Déplacement du curseur
        moveMouse(to: point)
        
        // 3. Gestion du Clic / Pression
        if packet.isActive {
            // Si c'est un "drag", on simule un bouton gauche maintenu
            simulateMouseEvent(type: .leftMouseDragged, position: point, pressure: packet.pressure)
        } else {
            // Relâchement
            simulateMouseEvent(type: .leftMouseUp, position: point, pressure: 0)
        }
    }
    
    private func moveMouse(to point: CGPoint) {
        // Déplacer sans cliquer (Hover) ou update position pour le drag
        // Note: leftMouseDragged inclut implicitement le mouvement
        let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left)
        event?.post(tap: .cghidEventTap)
    }
    
    private func simulateMouseEvent(type: CGEventType, position: CGPoint, pressure: CGFloat) {
        guard let event = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: position, mouseButton: .left) else { return }
        
        // Optionnel : Injection de la pression (tablette graphique)
        // C'est un champ integer pour CGEvent, échelle 0-255 souvent, ou via fields spécifiques
        // Utilisation d'un champ générique de pression tablette :
        event.setDoubleValueField(.tabletPressure, value: Double(pressure))
        
        // Pour simuler un clic, il faut souvent faire un MouseDown si on n'était pas déjà down
        // Simplification ici : on assume que l'iPad gère l'état 'isActive'
        if type == .leftMouseDragged {
             // Astuce : pour que le drag fonctionne, il faut s'assurer qu'un MouseDown a eu lieu avant.
             // Dans une implémentation robuste, on suivrait l'état "précédent".
             // Ici, on force le bouton à être considéré "appuyé".
             let downEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: position, mouseButton: .left)
             downEvent?.setDoubleValueField(.tabletPressure, value: Double(pressure))
             downEvent?.post(tap: .cghidEventTap)
        }
        
        event.post(tap: .cghidEventTap)
    }
}
