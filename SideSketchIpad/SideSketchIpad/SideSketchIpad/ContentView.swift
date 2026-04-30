import SwiftUI

struct ContentView: View {
    
    @StateObject private var connectivity = ConnectivityManager()
    @AppStorage("mac_ip_address") private var macIPAddress: String = ""
    @State private var showSettingsPopover = false
    
    var body: some View {
        NavigationStack {
            DrawingView(connectivity: connectivity)
                .navigationTitle("SideSketch")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            showSettingsPopover.toggle()
                        } label: {
                            HStack(spacing: 12) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(connectivity.isConnected ? Color.green : Color.red)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(connectivity.isConnected ? "Connecté" : "Déconnecté")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Image(systemName: "slider.horizontal.3")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 8)
                        }
                        .popover(isPresented: $showSettingsPopover, arrowEdge: .top) {
                            ConnectionSettingsView(
                                connectivity: connectivity,
                                macIPAddress: $macIPAddress
                            )
                            .frame(width: 360)
                            .presentationCompactAdaptation(.popover)
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
