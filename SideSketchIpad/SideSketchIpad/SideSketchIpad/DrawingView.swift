import SwiftUI

struct DrawingView: View {
    @ObservedObject var connectivity: ConnectivityManager

    @State private var trackerLocation: CGPoint? = nil
    @State private var trackerVisible = false

    var body: some View {
        ZStack {
            if connectivity.isConnected {
                TouchCaptureView(
                    connectivityManager: connectivity,
                    onTouchLocationChanged: { point in
                        trackerLocation = point
                        trackerVisible = true
                    },
                    onTouchEnded: {
                        trackerVisible = false
                    }
                )
                .padding(12)
                .overlay(alignment: .topLeading) {
                    Label("Zone active", systemImage: "pencil.tip")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(8)
                }
                .overlay {
                    if trackerVisible, let point = trackerLocation {
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
            } else {
                disconnectedPlaceholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.15), value: trackerVisible)
        .animation(.easeInOut(duration: 0.3), value: connectivity.isConnected)
        .background(Color(.systemBackground))
    }

    private var disconnectedPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "desktopcomputer.and.arrow.down")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)

            VStack(spacing: 8) {
                Text("Connectez-vous à votre Mac")
                    .font(.title3.bold())
                    .foregroundStyle(.primary)

                Text("""
1. Lancez SideSketchMac sur votre Mac
2. Notez l’IP affichée dans l’app Mac
3. Ouvrez les paramètres et saisissez l’IP
""")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            }
        }
        .padding(40)
    }
}
