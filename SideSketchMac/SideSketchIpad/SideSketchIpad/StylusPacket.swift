import Foundation
import CoreGraphics

struct StylusPacket: Codable, Sendable {
    let x: CGFloat
    let y: CGFloat
    let pressure: CGFloat
    let isActive: Bool
}
