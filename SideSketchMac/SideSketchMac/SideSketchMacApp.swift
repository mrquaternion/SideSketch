//
//  SideSketchMacApp.swift
//  SideSketchMac
//
//  Created by Yamir A. Poldo Silva on 2026-02-20.
//

import SwiftUI

@main
struct MacTabletApp: App {
    @StateObject private var receiver = ReceiverManager()

    var body: some Scene {
        WindowGroup {
            ContentView(receiver: receiver)
        }
    }
}
