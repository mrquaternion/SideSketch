import SwiftUI

enum DrawingToolbarItems {
    case pencil, eraser, text
}

struct DrawingView<Manager: ConnectivityManaging>: View {
    @ObservedObject var connectivity: Manager

    @State private var trackerLocation: CGPoint? = nil
    @State private var trackerVisible = false
    
    @State private var selectedItem: DrawingToolbarItems = .pencil
    @State private var openToolbar = false

    var body: some View {
        Group {
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
                .overlay {
                    if trackerVisible, let point = trackerLocation {
                        tracker(for: point)
                    }
                }
                .overlay(alignment: .topLeading) {
                    Label("Zone active", systemImage: "pencil.tip")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding([.leading, .top], 24)
                }
                .overlay(alignment: .topTrailing) {
                    drawingToolbar
                }
                .padding(.horizontal, 24)
            } else {
                disconnectedPlaceholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.15), value: trackerVisible)
        .animation(.easeInOut(duration: 0.3), value: connectivity.isConnected)
        .background(Color(.systemBackground))
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
    
    private var drawingToolbar: some View {
        HStack(spacing: 24) {
            if openToolbar {
                Button {
                    selectedItem = .pencil
                } label: {
                    Image(systemName: "pencil")
                        .font(.title2)
                        .foregroundStyle(selectedItem == .pencil ? .blue : .gray)
                }
                .buttonStyle(.plain)
                .transition(.move(edge: .trailing).combined(with: .opacity))
                
                Button {
                    selectedItem = .eraser
                } label: {
                    Image(systemName: "eraser.fill")
                        .font(.title2)
                        .foregroundStyle(selectedItem == .eraser ? .blue : .gray)
                }
                .buttonStyle(.plain)
                .transition(.move(edge: .trailing).combined(with: .opacity))
                
                Button {
                    selectedItem = .text
                } label: {
                    Image(systemName: "textformat")
                        .font(.title2)
                        .foregroundStyle(selectedItem == .text ? .blue : .gray)
                }
                .buttonStyle(.plain)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            
            Button {
                withAnimation(.bouncy) {
                    openToolbar.toggle()
                }
            } label: {
                Image(systemName: openToolbar ? "chevron.right" : "gearshape.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(.capsule)
        .shadow(radius: 1.5, y: 1)
        .padding([.trailing, .top], 24)
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

#Preview("Version non-connecté") {
    DrawingView(connectivity: MockConnectivityManager(shouldBeConnected: false))
}

#Preview("Version connecté (simulation)") {    
    DrawingView(connectivity: MockConnectivityManager(shouldBeConnected: true))
}

