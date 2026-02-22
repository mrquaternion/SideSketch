
import Foundation
import CoreGraphics
import AppKit

@MainActor
final class CursorController {

    private var wasActive: Bool = false

    func apply(packet: StylusPacket) {
        guard let screenPoint = convertToScreenPoint(normalizedX: packet.x, normalizedY: packet.y) else {
            return
        }

        CGWarpMouseCursorPosition(screenPoint)

        switch (wasActive, packet.isActive) {
        case (false, true):
            postMouseEvent(type: .leftMouseDown, at: screenPoint, pressure: packet.pressure)
        case (true, true):
            postMouseEvent(type: .leftMouseDragged, at: screenPoint, pressure: packet.pressure)
        case (true, false):
            postMouseEvent(type: .leftMouseUp, at: screenPoint, pressure: 0)
        case (false, false):
            postMouseEvent(type: .mouseMoved, at: screenPoint, pressure: 0)
        }

        wasActive = packet.isActive
    }

    // MARK: - Conversion Coordonnées (Fix Bug #2 : Retina)

    private func convertToScreenPoint(normalizedX: CGFloat, normalizedY: CGFloat) -> CGPoint? {

        let bounds = CGDisplayBounds(CGMainDisplayID())
        guard bounds.width > 0, bounds.height > 0 else { return nil }

        let x = normalizedX * bounds.width
        let y = normalizedY * bounds.height

        return CGPoint(x: x, y: y)
    }

    // MARK: - Événements CGEvent

    private func postMouseEvent(type: CGEventType, at point: CGPoint, pressure: CGFloat) {
        let isTrusted = AXIsProcessTrusted()
        if !isTrusted {
            // Pas de spam dans les logs — on ne log que pour les down/up
            if type == .leftMouseDown {
                print("[CursorController] Accessibilité refusée — clics ignorés")
            }
            return
        }

        guard let event = CGEvent(
            mouseEventSource: nil,
            mouseType: type,
            mouseCursorPosition: point,
            mouseButton: type == .mouseMoved ? .center : .left
        ) else { return }

        if type == .leftMouseDown || type == .leftMouseDragged {
            event.setDoubleValueField(.mouseEventPressure, value: Double(pressure))
        }

        event.post(tap: .cghidEventTap)
    }
}
