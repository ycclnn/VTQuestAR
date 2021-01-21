//
//  PhotoCaptureView.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/6.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI

//Get the note image
struct PhotoCaptureView: View {
    @Binding var showImagePicker: Bool
     @Binding var photoImageData: Data?
    
     let cameraOrLibrary: String
    
     var body: some View {
        
         ImagePicker(imagePickerShown: $showImagePicker,
                     photoImageData: $photoImageData,
                     cameraOrLibrary: cameraOrLibrary).onAppear() {
                        print("cAME \(cameraOrLibrary)")
                     }
     }
}


