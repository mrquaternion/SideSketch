//
//  touchCaptureView.swift
//  
//
//  Created by Yamir A. Poldo Silva on 2026-02-20.
//

import SwiftUI
import PencilKit

struct DrawingPad: UIViewRepresentable {
    var connectionManager: ConnectivityManager
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        // On désactive le dessin local pour ne pas surcharger le processeur graphique de l'iPad
        // Si vous voulez voir le trait sur l'iPad, mettez .default
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .clear, width: 5)
        canvas.backgroundColor = .darkGray
        
        // On attache un GestureRecognizer personnalisé pour intercepter les données brutes
        let captureGesture = StylusGestureRecognizer(target: nil, action: nil)
        captureGesture.manager = connectionManager
        canvas.addGestureRecognizer(captureGesture)
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

// Classe qui intercepte les touches
class StylusGestureRecognizer: UIGestureRecognizer {
    weak var manager: ConnectivityManager?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        processTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        processTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        sendEndState(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        sendEndState(touches)
    }
    
    private func processTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first, let view = self.view else { return }
        
        // Normalisation (0.0 à 1.0)
        let location = touch.location(in: view)
        let normX = location.x / view.bounds.width
        let normY = location.y / view.bounds.height
        
        // Création du paquet
        let packet = StylusPacket(
            x: normX,
            y: normY,
            pressure: touch.force, // Pression
            isActive: true // Le stylet touche l'écran
        )
        manager?.send(packet: packet)
    }
    
    private func sendEndState(_ touches: Set<UITouch>) {
        guard let touch = touches.first, let view = self.view else { return }
        let location = touch.location(in: view)
        
        let packet = StylusPacket(
            x: location.x / view.bounds.width,
            y: location.y / view.bounds.height,
            pressure: 0.0,
            isActive: false // Relâchement
        )
        manager?.send(packet: packet)
    }
}
