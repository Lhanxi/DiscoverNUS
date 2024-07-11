//
//  CompleteQuest.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 28/6/24.
//

import SwiftUI
import ARKit

struct ARCameraView: UIViewRepresentable {
    let questImage: UIImage
    @Binding var isImageDetected: Bool

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        let configuration = ARImageTrackingConfiguration()
        
        let referenceImage = ARReferenceImage(questImage.cgImage!, orientation: .up, physicalWidth: 0.2)
        
        configuration.trackingImages = [referenceImage]
            
        uiView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARCameraView

        init(_ parent: ARCameraView) {
            self.parent = parent
        }

        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            if let imageAnchor = anchor as? ARImageAnchor {
                DispatchQueue.main.async {
                    self.parent.isImageDetected = true
                }
            } else {
                DispatchQueue.main.async {
                    self.parent.isImageDetected = false
                }
            }
        }
    }
}

//implement backward navigation etc later on when every bug is solved
struct CompleteQuest: View {
    let quest: Quest
    @State private var isImageDetected = false
    @Binding var showSignInView: Bool
    @Binding var playerInfo: Player
    @State var navigateBackwards = false
    @State var navigateForward = false
    @State var timer: Int

    var body: some View {
        ZStack{
            VStack {
                ARCameraView(questImage: quest.image, isImageDetected: $isImageDetected)
                    .edgesIgnoringSafeArea(.all)
                    .statusBar(hidden: true)
                
                NavigationLink(destination: RootView(), isActive: $navigateForward) {
                }
                .hidden()
                NavigationLink(destination: StartQuest(quest: quest, timer: timer, showSignInView: $showSignInView, playerInfo: self.playerInfo), isActive: $navigateBackwards) {
                }
                .hidden()
                .navigationBarHidden(true)
            }.onChange(of: isImageDetected) { result in
                if result {
                    //level up etc later on when everything works
                    self.navigateForward = true
                }
            }
            
            VStack{
                HStack{
                    Button(action: {
                        self.navigateBackwards = true
                    }) {
                        Text("Back")
                            .padding(10)
                    }
                    Spacer()
                }
                Text("\(timer)")
                    .padding(10)
                    .onAppear() {
                        self.startTimer()
                    }
                Spacer()
            }
        }
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { result in
            if self.timer > 0 {
                self.timer -= 1
            } else {
                self.navigateForward = true
            }
        }
    }
}
