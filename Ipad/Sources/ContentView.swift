//
//  ContentView.swift
//  
//
//  Created by Yamir A. Poldo Silva on 2026-02-20.
//

struct ContentView: View {
    @StateObject var manager = ConnectivityManager()
    
    var body: some View {
        ZStack {
            DrawingPad(connectionManager: manager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Circle()
                        .fill(manager.isConnected ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(manager.isConnected ? "Connecté au Mac" : "Recherche...")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
                Spacer()
            }
            .padding()
        }
    }
}
