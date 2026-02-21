//
//  CursorController.swift
//  SideSketchMac
//
//  Created by Yamir A. Poldo Silva on 2026-02-20.
//


import Cocoa
import CoreGraphics

final class CursorController {

    // État interne : est-ce qu'on est en "clic maintenu" ?
    private var isMouseDown = false

    // Récupération de l'écran principal
    private var screenFrame: CGRect {
        NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1920, height: 1080)
    }

    func processPacket(_ packet: StylusPacket) {
        // 1) Dénormalisation 0.0–1.0 -> coordonnées écran
        let targetX = packet.x * screenFrame.width + screenFrame.origin.x
        let targetY = packet.y * screenFrame.height + screenFrame.origin.y

        let point = CGPoint(x: targetX, y: targetY)

        // 2) Gestion hover / down / drag / up
        if packet.isActive {
            if !isMouseDown {
                // Début du clic
                postMouseEvent(type: .leftMouseDown, position: point)
                isMouseDown = true
            } else {
                // Drag (clic maintenu + mouvement)
                postMouseEvent(type: .leftMouseDragged, position: point)
            }
        } else {
            if isMouseDown {
                // Relâchement
                postMouseEvent(type: .leftMouseUp, position: point)
                isMouseDown = false
            } else {
                // Simple déplacement du curseur (hover)
                postMouseEvent(type: .mouseMoved, position: point)
            }
        }
    }

    private func postMouseEvent(type: CGEventType, position: CGPoint) {
        let button: CGMouseButton = .left

        guard let event = CGEvent(
            mouseEventSource: nil,
            mouseType: type,
            mouseCursorPosition: position,
            mouseButton: button
        ) else { return }

        event.post(tap: .cghidEventTap)
    }
}
