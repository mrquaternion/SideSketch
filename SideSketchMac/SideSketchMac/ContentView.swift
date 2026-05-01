//
//  ContentView.swift
//  SideSketchMac
//
//  Created by Mathias La Rochelle on 2026-05-01.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var manager: ReceiverManager
    @EnvironmentObject var model: CanvasModel
    
    var body: some View {
        ZStack {
            CanvasView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ReceiverManager(canvasModel: CanvasModel()))
}
