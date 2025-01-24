//
//  ContentView.swift
//  FlyingCubeTest3
//
//  Created by Nathan Eriksen on 1/23/25.
//

import SwiftUI
import RealityKit

var origin = Entity()
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}
struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    var body: some View {
        VStack {
            if appModel.immersiveSpaceState != .open {
                Text("Turn immersion environment style up before opening immersive space. When you open the immersive space with immersion on, the cube will look choppy and flicker as it moves. if you leave the space and reopen the space with immersion off, the cube will smoothly as it should.").padding()
            }
                if appModel.immersiveSpaceState == .open {
                    Text("Watch Cube closely as it goes over head. notice its choppy. if you take headset off while in this space and put it back on and send another cube, it will look smooth. If you also launch this space with the immersion level all the way down, the cube will also move smoothly as it should.").padding()
                    
                    Button {
                        spawnCubeThatLagsWhenYouLaunchWithImmersionOn()
                    } label: {
                        Text("Send Cube")
                    }
                }
            ToggleImmersiveSpaceButton()
        }
        .padding()
    }
}
struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            spawnCubeThatLagsWhenYouLaunchWithImmersionOn()
            content.add(origin)
        }
    }
}
func spawnCubeThatLagsWhenYouLaunchWithImmersionOn(){
    
    var zPos: Float = -90
    
    for _ in 0..<10 {
        let cube = ModelEntity(mesh: .generateBox(size: [5,0.1,1]), materials: [UnlitMaterial(color: .green)])
        cube.components.set(CollisionComponent(shapes: [.generateBox(size: [1,1,1])]))
        cube.components.set(PhysicsBodyComponent(massProperties: .default, material: .default, mode: .kinematic))
        cube.components.set(PhysicsMotionComponent(linearVelocity: [0,0,15]))
        cube.position = [-1,3,zPos]
        zPos -= 2
        origin.addChild(cube)
    }

    
    
}
struct ToggleImmersiveSpaceButton: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    var body: some View {
        Button {
            Task { @MainActor in
                switch appModel.immersiveSpaceState {
                case .open:
                    appModel.immersiveSpaceState = .inTransition
                    await dismissImmersiveSpace()
                case .closed:
                    appModel.immersiveSpaceState = .inTransition
                    switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                    case .opened:
                        break
                    case .userCancelled, .error:
                        fallthrough
                    @unknown default:
                        appModel.immersiveSpaceState = .closed
                    }
                    
                case .inTransition:
                    break
                }
            }
        } label: {
            Text(appModel.immersiveSpaceState == .open ? "Hide Immersive Space" : "Show Immersive Space")
        }
        .disabled(appModel.immersiveSpaceState == .inTransition)
        .animation(.none, value: 0)
        .fontWeight(.semibold)
    }
}
