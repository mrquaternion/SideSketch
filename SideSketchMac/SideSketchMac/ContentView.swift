//
//  ContentView.swift
//  SideSketchMac
//
//  Created by Yamir A. Poldo Silva on 2026-02-20.
//

import SwiftUI

struct ContentView: View {
    @StateObject  var receiver: ReceiverManager

    var body: some View {
        VStack {
            Image(systemName: "ipad.and.arrow.forward")
                .font(.system(size: 50))
                .padding()

            Text("Serveur Tablette Graphique")
                .font(.title)

            Text(receiver.connectionStatus)
                .foregroundColor(.secondary)
                .padding()

            Text("Note: Assurez-vous d'avoir accordé les permissions d'Accessibilité.")
                .font(.caption)
                .foregroundColor(.red)
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}
