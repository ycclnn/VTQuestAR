//
//  arPhoto.swift
//  VTQuestAR
//
//  Created by zhennan on 2020/7/21.
//

import SwiftUI

/// a single arPhoto object used to represent/store info of a photo in carousel list.
struct arPhotoCarousel : Identifiable  {
    

    
    /// ID
    var id : Int?
    
    /// Image data
    var img : UIImage?
    
    /// image name
    var dateCaptured : String?

    
    /// Is true when the photo is currently viewed by the user.
    var show : Bool?
    
    /// latitude
    var lat: Double?
    
    /// longitude
    var long: Double?
}

