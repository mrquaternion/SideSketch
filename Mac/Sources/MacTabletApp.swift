//
//  MacTabletApp.swift
//  
//
//  Created by Yamir A. Poldo Silva on 2026-02-20.
//


@main
struct MacTabletApp: App {
    @StateObject var receiver = ReceiverManager()
    
    var body: some Scene {
        WindowGroup {
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
        }
    }
}