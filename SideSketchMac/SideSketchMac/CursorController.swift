import Foundation
import CoreGraphics
import AppKit

// Plus nécessaire pour le moment. Aussi, est-ce que la variable `pressure` de StylusPacket est encore nécessaire ?


//@MainActor
//final class CursorController {
//
//    private var wasActive: Bool = false
//    private let sensitivity: CGFloat = 1.6
//    var window: NSWindow?
//
//    func apply(packet: StylusPacket) {
//        guard let newPoint = computeNextCursorPoint(from: packet) else {
//            return
//        }
//
//        CGWarpMouseCursorPosition(newPoint)
//
//        switch (wasActive, packet.isActive) {
//        case (false, true):
//            postMouseEvent(type: .leftMouseDown, at: newPoint, pressure: packet.pressure)
//
//        case (true, true):
//            postMouseEvent(type: .leftMouseDragged, at: newPoint, pressure: packet.pressure)
//
//        case (true, false):
//            postMouseEvent(type: .leftMouseUp, at: newPoint, pressure: 0)
//
//        case (false, false):
//            postMouseEvent(type: .mouseMoved, at: newPoint, pressure: 0)
//        }
//
//        wasActive = packet.isActive
//    }
//
//    func resetInteractionState() {
//        wasActive = false
//    }
//
//    private func computeNextCursorPoint(from packet: StylusPacket) -> CGPoint? {
//        guard let currentLocation = CGEvent(source: nil)?.location, let window else {
//            return nil
//        }
//        
//        let frame = window.frame
//        
//        let deltaXInPixels = packet.deltaX * frame.width * sensitivity
//        let deltaYInPixels = packet.deltaY * frame.height * sensitivity
//
//        let newX = currentLocation.x + deltaXInPixels
//        let newY = currentLocation.y + deltaYInPixels
//
//        let clampedX = min(max(newX, frame.minX), frame.maxX - 1)
//        let clampedY = min(max(newY, frame.minY), frame.maxY - 1)
//
//        return CGPoint(x: clampedX, y: clampedY)
//    }
//
//    private func postMouseEvent(type: CGEventType, at point: CGPoint, pressure: CGFloat) {
//        let isTrusted = AXIsProcessTrusted()
//        if !isTrusted {
//            if type == .leftMouseDown {
//                print("[CursorController] Accessibilité refusée — clics ignorés")
//            }
//            return
//        }
//
//        guard let event = CGEvent(
//            mouseEventSource: nil,
//            mouseType: type,
//            mouseCursorPosition: point,
//            mouseButton: type == .mouseMoved ? .center : .left
//        ) else { return }
//
//        if type == .leftMouseDown || type == .leftMouseDragged {
//            event.setDoubleValueField(.mouseEventPressure, value: Double(pressure))
//        }
//
//        event.post(tap: .cghidEventTap)
//    }
//}
