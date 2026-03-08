import Foundation
import CoreGraphics

struct StylusPacket: Codable, Sendable {
    let deltaX: CGFloat
    let deltaY: CGFloat
    let pressure: CGFloat
    let isActive: Bool
}
