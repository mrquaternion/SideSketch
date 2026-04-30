import SwiftUI
import UIKit

struct TouchCaptureView<Manager: ConnectivityManaging>: UIViewRepresentable {
    
    let connectivityManager: Manager
    var onTouchLocationChanged: ((CGPoint) -> Void)? = nil
    var onTouchEnded: (() -> Void)? = nil

    func makeUIView(context: Context) -> TouchCaptureUIView {
        let view = TouchCaptureUIView()
        view.connectivityManager = connectivityManager
        view.onTouchLocationChanged = onTouchLocationChanged
        view.onTouchEnded = onTouchEnded
        view.isMultipleTouchEnabled = false
        return view
    }

    func updateUIView(_ uiView: TouchCaptureUIView, context: Context) {
        uiView.connectivityManager = connectivityManager
        uiView.onTouchLocationChanged = onTouchLocationChanged
        uiView.onTouchEnded = onTouchEnded
    }
}

final class TouchCaptureUIView: UIView {

    var connectivityManager: (any ConnectivityManaging)?
    var onTouchLocationChanged: ((CGPoint) -> Void)?
    var onTouchEnded: (() -> Void)?

    private var lastLocation: CGPoint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.systemBackground
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.cornerRadius = 24
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }

        let location = touch.preciseLocation(in: self)
        lastLocation = location
        onTouchLocationChanged?(location)

        let packet = StylusPacket(
            deltaX: 0,
            deltaY: 0,
            pressure: normalizedPressure(for: touch, isActive: true),
            isActive: true
        )

        Task { @MainActor [weak self] in
            self?.connectivityManager?.send(packet: packet)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let event else { return }

        let coalesced = event.coalescedTouches(for: touch) ?? [touch]

        for t in coalesced {
            sendRelativePacket(from: t, isActive: true)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }

        sendRelativePacket(from: touch, isActive: false)
        lastLocation = nil
        onTouchEnded?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard let touch = touches.first else { return }

        sendRelativePacket(from: touch, isActive: false)
        lastLocation = nil
        onTouchEnded?()
    }

    private func sendRelativePacket(from touch: UITouch, isActive: Bool) {
        let location = touch.preciseLocation(in: self)
        onTouchLocationChanged?(location)

        guard let previous = lastLocation else {
            lastLocation = location
            return
        }

        let bounds = self.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        let dx = location.x - previous.x
        let dy = location.y - previous.y

        lastLocation = location

        let normalizedDX = dx / bounds.width
        let normalizedDY = dy / bounds.height

        let packet = StylusPacket(
            deltaX: normalizedDX,
            deltaY: normalizedDY,
            pressure: normalizedPressure(for: touch, isActive: isActive),
            isActive: isActive
        )

        Task { @MainActor [weak self] in
            self?.connectivityManager?.send(packet: packet)
        }
    }

    private func normalizedPressure(for touch: UITouch, isActive: Bool) -> CGFloat {
        if touch.maximumPossibleForce > 0 {
            return touch.force / touch.maximumPossibleForce
        } else {
            return isActive ? 0.5 : 0.0
        }
    }
}
