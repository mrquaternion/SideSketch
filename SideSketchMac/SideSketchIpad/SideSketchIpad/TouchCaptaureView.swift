import SwiftUI
import UIKit

struct TouchCaptureView: UIViewRepresentable {
    let connectivityManager: ConnectivityManager

    func makeUIView(context: Context) -> TouchCaptureUIView {
        let view = TouchCaptureUIView()
        view.connectivityManager = connectivityManager
        view.isMultipleTouchEnabled = false
        return view
    }

    func updateUIView(_ uiView: TouchCaptureUIView, context: Context) {
        uiView.connectivityManager = connectivityManager
    }
}

final class TouchCaptureUIView: UIView {

    var connectivityManager: ConnectivityManager?

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = UIColor.systemBackground
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.cornerRadius = 12
    }

    // MARK: - Capture Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        sendPacket(from: touch, isActive: true)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let event else { return }

        let coalesced = event.coalescedTouches(for: touch) ?? [touch]
        for t in coalesced {
            sendPacket(from: t, isActive: true)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        sendPacket(from: touch, isActive: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard let touch = touches.first else { return }
        sendPacket(from: touch, isActive: false)
    }

    // MARK: - Construction et envoi du paquet

    private func sendPacket(from touch: UITouch, isActive: Bool) {
        let location = touch.preciseLocation(in: self)
        let bounds = self.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        let normalizedX = max(0, min(1, location.x / bounds.width))
        let normalizedY = max(0, min(1, location.y / bounds.height))
        
        let pressure: CGFloat
        if touch.type == .pencil && touch.maximumPossibleForce > 0 {
            pressure = touch.force / touch.maximumPossibleForce
        } else if touch.maximumPossibleForce > 0 {
            pressure = touch.force / touch.maximumPossibleForce
        } else {
            pressure = isActive ? 0.5 : 0.0
        }

        let packet = StylusPacket(
            x: normalizedX,
            y: normalizedY,
            pressure: pressure,
            isActive: isActive
        )

        Task { @MainActor [weak self] in
            self?.connectivityManager?.send(packet: packet)
        }
    }
}
