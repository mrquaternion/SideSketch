//
//  StylusPacket.swift
//  SideSketchMac
//
//  Created by Yamir A. Poldo Silva on 2026-02-20.
//


import Foundation
import CoreGraphics

struct StylusPacket: Codable, Sendable {
    let x: CGFloat
    let y: CGFloat
    let pressure: CGFloat
    let isActive: Bool
}
