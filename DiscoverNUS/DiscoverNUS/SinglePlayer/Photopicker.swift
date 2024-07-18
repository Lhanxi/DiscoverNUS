//
//  Photopicker.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 13/7/24.
//

import Foundation
import SwiftUI
import PhotosUI

struct UserPhotoPicker: View {
    @State var selectedPhoto: PhotosPickerItem?
    @State var userImage: Image
    @State var userID: String
    @State var convertedImage: UIImage?
    
    var body: some View {
        let diameter: CGFloat = 120
        ZStack {
            userImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: diameter, height: diameter)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                .padding(10)
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                VStack{
                    HStack{
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 40, height: 40)
                                .opacity(0.8)
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .font(Font.system(size: 20, weight: .bold))
                        }
                    }
                    .padding(.trailing, 120)
                }
                .padding(.top, 85)
            }
        }

        .onChange(of: selectedPhoto) { selectedPhoto in
            if let selectedPhoto = selectedPhoto {
                Task {
                    do {
                        let currentImage = try await self.retrieveImage(selectedPhoto: selectedPhoto)
                        try ImageHandler().updateImage(url: "users/\(userID)", image: currentImage)
                        self.userImage = Image(uiImage: currentImage)
                    }
                }
            }
        }
    }

    
    private func retrieveImage(selectedPhoto: PhotosPickerItem) async throws -> UIImage {
        if let photoData = try? await selectedPhoto.loadTransferable(type: Data.self) {
            if let selectedImage = UIImage(data: photoData) {
                return selectedImage
            } else {
                throw URLError(.badServerResponse)
            }
        } else {
            throw URLError(.badServerResponse)
        }
    }
}
