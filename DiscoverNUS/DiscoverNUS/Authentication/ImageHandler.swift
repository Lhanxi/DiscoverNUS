//
//  ProfilePictureHandler.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 8/6/24.
//

import FirebaseStorage
import SwiftUI

//can dump this into error file later on and customise error message
enum ImageError: Error {
    case imageProcessingError
    case fileSizeExceedError
    case imageUploadError
}

class ImageHandler {
    let maxSize: Int64 = 5 * 1024 * 1024
    
    public func getImage(url: String, completion: @escaping (UIImage?) -> Void) {
        let storage = Storage.storage()
        let imageReference = storage.reference().child(url)
        
        imageReference.getData(maxSize: maxSize) { data, error in
            if let error = error {
                print("no such URL")
                completion(UIImage(imageLiteralResourceName: "default_person"))
            } else {
                let retrievedImage = UIImage(data: data!) ?? UIImage(imageLiteralResourceName: "default_person")
                completion(retrievedImage)
            }
        }
    }
    
    //can go back to this function later on to see if any better way of handling errors
    public func updateImage(url: String, image: UIImage) throws {
        var compression = 1.0
        let storage = Storage.storage()
        let imageReference = storage.reference().child(url)
        
        guard let imageData = image.jpegData(compressionQuality: compression) else {
            throw(ImageError.imageProcessingError)
        }
        while imageData.count > maxSize && compression > 0.1 {
            compression -= 0.1
            guard let imageData = image.jpegData(compressionQuality: compression) else {
                throw(ImageError.imageProcessingError)
            }
        }
        
        if imageData.count > maxSize && compression <= 0.1 {
            throw(ImageError.fileSizeExceedError)
        }
        
        imageReference.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Success")
            }
        }
    }
}


