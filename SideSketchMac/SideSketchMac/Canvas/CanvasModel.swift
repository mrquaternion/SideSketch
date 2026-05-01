//
//  CanvasModel.swift
//  SideSketchMac
//
//  Created by Mathias La Rochelle on 2026-05-01.
//

import Combine
import AppKit

final class CanvasModel: ObservableObject {
    @Published var cursorPosition: CGPoint = .zero
    @Published var canvasSize: CGSize = .zero
    @Published var isDrawing = false
    @Published var lines = [Line]()
    
    private var wasActive: Bool = false
    
    func apply(packet: StylusPacket) {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return }
        
        isDrawing = packet.isActive // puisque pour arriver ici, il faut que packet.isEmpty soit false
        
        let dx = packet.deltaX * canvasSize.width
        let dy = packet.deltaY * canvasSize.height
        
        cursorPosition.x = min(max(cursorPosition.x + dx, 0), canvasSize.width)
        cursorPosition.y = min(max(cursorPosition.y + dy, 0), canvasSize.height)
        
        switch (wasActive, packet.isActive) {
        case (false, true):
            startNewStroke(at: cursorPosition)
        case (true, true):
            continueStroke(by: cursorPosition)
        case (true, false):
            stopStroke()
        case (false, false):
            break
        }
        
        wasActive = packet.isActive
    }
    
    func startNewStroke(at newPoint: CGPoint) {
        lines.append(Line(points: [newPoint], color: NSColor.black, lineWidth: 1))
    }
    
    func continueStroke(by newPoint: CGPoint) {
        let index = lines.count - 1
        lines[index].points.append(newPoint)
    }
    
    func stopStroke() {
        
    }
}
