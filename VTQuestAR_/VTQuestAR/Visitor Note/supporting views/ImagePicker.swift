//
//  ImagePicker.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/6.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import Foundation
import SwiftUI
 
// Global variable
var pickedImage = UIImage()
 
/*
 For storage and performance efficiency reasons, we scale down the
 park photo image selected by the user from the photo library
 or taken by camera to a smaller size, which is called a "thumbnail"
 */
let thumbnailImageWidth: CGFloat = 600.0
let thumbnailImageHeight: CGFloat = 600.0
 
/*
********************************
MARK: - Image Picker Coordinator
********************************
*/
class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    /*
    🔴 imagePickerShown and photoImageData are passed as input parameters.
    The @Binding keyword indicates that the input parameter is changeable.
    */
   
    @Binding var imagePickerShown: Bool
    @Binding var photoImageData: Data?
   
    init(imagePickerShown: Binding<Bool>, photoImageData: Binding<Data?>) {
        _imagePickerShown = imagePickerShown
        _photoImageData = photoImageData
    }
   
    /*
     UIImagePickerController is a view controller that manages the system interfaces for
     taking pictures, recording movies, and choosing items from the user's media library.
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        if let editedImage = info[.editedImage] as? UIImage {
            pickedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            pickedImage = originalImage
        } else {
            photoImageData = nil
            return
        }
 
        // Scale the picked image to the thumbnail size for storage and performance efficiency reasons.
        // The scale() method is given below as an extension of the UIImage class.
       
        let thumbnailImage = pickedImage.scale(toSize: CGSize(width: thumbnailImageWidth, height: thumbnailImageHeight))
       
        // jpegData returns a data object containing thumbnailImage in JPEG format.
        if let thumbnailData = thumbnailImage.jpegData(compressionQuality: 1.0) {
            /*
             🔴 Changing photoImageData value here is reflected in the @State private var photoImageData
                in AddSong.swift and ChangeSong.swift because of the @Binding keyword.
             */
            photoImageData = thumbnailData
        } else {
            photoImageData = nil
        }
       
        /*
        🔴 Changing imagePickerShown value here is reflected in the @State private var showImagePicker
           in AddSong.swift and ChangeSong.swift because of the @Binding keyword.
        */
       
        // Since the photo image data is obtained close it
        imagePickerShown = false
           
    }
   
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        /*
        🔴 Changing imagePickerShown value here is reflected in the @State private var showImagePicker
           in AddSong.swift and ChangeSong.swift because of the @Binding keyword.
        */
       
        // To cancel close it
        imagePickerShown = false
       
        picker.dismiss(animated: true, completion: nil)
    }
   
}
 
/*
*************************************************
MARK: - Image Picker from Camera or Photo Library
*************************************************
*/
struct ImagePicker: UIViewControllerRepresentable {
   
    @Binding var imagePickerShown: Bool
    @Binding var photoImageData: Data?
    let cameraOrLibrary: String
   
    func makeCoordinator() -> ImagePickerCoordinator {
        return ImagePickerCoordinator(imagePickerShown: $imagePickerShown, photoImageData: $photoImageData)
    }
   
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
       
        // Create a UIImagePickerController object, initialize it,
        // and store its object reference into imagePickerController
        let imagePickerController = UIImagePickerController()
       
        if cameraOrLibrary == "Camera" {
            imagePickerController.sourceType = .camera
        } else {
            imagePickerController.sourceType = .photoLibrary
        }
       
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = ["public.image"]
       
        // Designate this view controller as the delegate so that we can implement
        // the protocol methods in the ImagePickerCoordinator class above
        imagePickerController.delegate = context.coordinator
       
        return imagePickerController
    }
   
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // Unused
    }
   
}
 
/*
 ---------------------------------------------
 MARK: - Extension Methods to Resize a UIImage
 ---------------------------------------------
 */
 
// Resize a UIImage proportionately without distorting it
extension UIImage {
   
    func scale(toSize newSize:CGSize) -> UIImage {
        /*
         Make sure that the new size has the correct aspect ratio
         by calling the CGSize extension method resizeFill() below
        */
        let aspectFill = self.size.resizeFill(toSize: newSize)
       
        UIGraphicsBeginImageContextWithOptions(aspectFill, false, 0.0);
        self.draw(in: CGRect(origin: .zero, size: CGSize(width: aspectFill.width, height: aspectFill.height)))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
       
        return newImage
    }
}
 
extension CGSize {
   
    func resizeFill(toSize: CGSize) -> CGSize {
        let scale : CGFloat = (self.height / self.width) < (toSize.height / toSize.width) ? (self.height / toSize.height) : (self.width / toSize.width)
        return CGSize(width: (self.width / scale), height: (self.height / scale))
    }
}
 
 
