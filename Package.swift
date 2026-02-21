// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SideSketch",
    // Définition des plateformes minimales pour supporter SwiftUI moderne et la concurrence
    platforms: [
        .macOS(.v13), // Ventura ou plus (pour une meilleure gestion des API)
        .iOS(.v16)    // iPadOS 16+
    ],
    products: [
        // Bibliothèque partagée (modèles de données)
        .library(
            name: "DrawingProtocol",
            targets: ["DrawingProtocol"]
        ),
        // Exécutable pour le Mac (Récepteur)
        .executable(
            name: "SideSketchMac",
            targets: ["SideSketchMac"]
        ),
        // Exécutable pour l'iPad (Émetteur)
        .executable(
            name: "SideSketchiPad",
            targets: ["SideSketchiPad"]
        )
    ],
    dependencies: [ ],
    targets: [
        // --- 1. Module Partagé ---
        .target(
            name: "DrawingProtocol",
            dependencies: [],
            path: "DrawingProtocol"
        ),
        
        // --- 2. Application Mac (Récepteur) ---
        .executableTarget(
            name: "SideSketchMac",
            dependencies: ["DrawingProtocol"],
            path: "Mac",
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        ),
        
        // --- 3. Application iPad (Émetteur) ---
        .executableTarget(
            name: "SideSketchiPad",
            dependencies: ["DrawingProtocol"],
            path: "iPad",
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
