//
//  CanvasView.swift
//  SideSketchMac
//
//  Created by Mathias La Rochelle on 2026-05-01.
//

import SwiftUI

struct CanvasView: View {
    
    @EnvironmentObject var model: CanvasModel
    
    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                for line in model.lines {
                    var path = Path()
                    path.addLines(line.points)
                    
                    context.stroke(path, with: .color(Color(line.color)), lineWidth: line.lineWidth)
                }
            }
            .overlay {
                if model.isDrawing {
                    tracker(for: model.cursorPosition)
                }
            }
            .onAppear {
                model.canvasSize = proxy.size
            }
            .onChange(of: proxy.size) { _, newSize in
                model.canvasSize = newSize
            }
        }
    }
    
    private func tracker(for point: CGPoint) -> some View {
        ZStack {
            Circle()
                .stroke(.blue.opacity(0.9), lineWidth: 2)
                .frame(width: 28, height: 28)

            Circle()
                .fill(.blue)
                .frame(width: 8, height: 8)
        }
        .position(point)
        .allowsHitTesting(false)
    }
}

#Preview {
    CanvasView()
        .environmentObject(CanvasModel())
}
