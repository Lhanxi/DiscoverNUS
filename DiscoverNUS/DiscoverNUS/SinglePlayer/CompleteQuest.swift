//
//  CompleteQuest.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 28/6/24.
//

import SwiftUI
import PhotosUI
import Vision

class ImageComparison {
    static func compare(image1: Image, image2: Image, completion: @escaping (Bool) -> Void) {
        var feature1: VNFeaturePrintObservation?
        var feature2: VNFeaturePrintObservation?
        
        let group = DispatchGroup()
        
        group.enter()
        ImageComparison.process(image: image1) { feature in
            feature1 = feature
            group.leave()
        }
        
        group.enter()
        ImageComparison.process(image: image2) { feature in
            feature2 = feature 
            group.leave()
        }
        
        var featureDistance:Float = .infinity
         
        group.notify(queue: .main) {
            do {
                try feature1?.computeDistance(&featureDistance, to: feature2!)
                print(featureDistance)
                completion(featureDistance < 0.82)
            } catch {
                print("error: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    private static func process(image: Image, completion: @escaping (VNFeaturePrintObservation) -> Void) {
        DispatchQueue.main.async {
            let image = CIImage(cgImage: ImageRenderer(content: image).cgImage!)
            
            let request = VNGenerateImageFeaturePrintRequest()
            let requestHandler = VNImageRequestHandler(ciImage: image,
                                                       options: [:])
            
            do {
                try requestHandler.perform([request])
            } catch {
                print(error)
            }
            
            if let imageFeature = request.results?.first as? VNFeaturePrintObservation {
                print("hi")
                completion(imageFeature)
            }
        }
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var isImageDetected: Bool
    @Binding var questImage: Image
    @Binding var selectedImage: Image?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.delegate = context.coordinator
        controller.sourceType = .camera
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: ImagePickerView
        
        init(picker: ImagePickerView) {
            self.picker = picker
        }
        
        func imagePickerController(_ controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                picker.selectedImage = Image(uiImage: selectedImage)
                picker.isImageDetected = true
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
    @State var timeLimit: Int
    @State var questImage: Image
    @State var selectedImage: Image?
    @State var alertToGoBack = false
    @State var levelUp = false
    @State var currentExp: Int
    

    var body: some View {
        ZStack{
            VStack {
                ImagePickerView(isImageDetected: $isImageDetected, questImage: $questImage, selectedImage: $selectedImage)
                    .edgesIgnoringSafeArea(.all)
                    .statusBar(hidden: true)
                
                NavigationLink(destination: QuestSuccessfulView(quest: quest, timeLimit: quest.timelimit, showSignInView: $showSignInView, playerInfo: playerInfo, levelUp: levelUp, expGained: quest.expGained, currentExp: currentExp), isActive: $navigateForward) {
                }
                .hidden()
                NavigationLink(destination: StartQuest(quest: quest, timeLimit: timeLimit, showSignInView: $showSignInView, playerInfo: self.playerInfo), isActive: $navigateBackwards) {
                }
                .hidden()
                .navigationBarHidden(true)
            }.onChange(of: isImageDetected) { result in
                if result == true {
                    ImageComparison.compare(image1: questImage, image2: selectedImage!) { result in
                        if result {
                            LevelSystem.expGainManager(userID: playerInfo.id!, level: playerInfo.level, expGained: quest.expGained, currentExp: playerInfo.exp, questID: quest.name, questIDArray: playerInfo.quests) { error in
                                if let error = error {
                                    print("error")
                                } else if LevelSystem.levelUp {
                                    self.levelUp = true
                                    self.navigateForward = true
                                } else {
                                    self.navigateForward = true
                                }
                            }
                        } else {
                            self.alertToGoBack = true
                        }
                    }
                }
            }.alert(isPresented: $alertToGoBack) {
                Alert(
                    title: Text("Wrong Image"),
                    message: Text("Image not similar to requested image"),
                    dismissButton: .default(Text("Return")){
                        self.navigateBackwards = true
                    })
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
                Text("\(timeLimit)")
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
            if self.timeLimit > 0 {
                self.timeLimit -= 1
            } else {
                self.navigateBackwards = true
            }
        }
    }
}
