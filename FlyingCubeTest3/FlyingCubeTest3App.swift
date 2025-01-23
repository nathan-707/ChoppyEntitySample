//
//  FlyingCubeTest3App.swift
//  FlyingCubeTest3
//
//  Created by Nathan Eriksen on 1/23/25.
//

import SwiftUI
@main
struct FlyingCubeTest3App: App {
    @State private var appModel = AppModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
