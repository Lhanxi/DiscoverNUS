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
        userImage
            .resizable()
            .frame(width: 200, height: 100)
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            Image(systemName: "pencil")
        }.onChange(of: selectedPhoto) { selectedPhoto in
            if let selectedPhoto = selectedPhoto {
                Task {
                    do{
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
