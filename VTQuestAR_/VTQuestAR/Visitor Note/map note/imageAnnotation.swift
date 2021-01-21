//
//  imageAnnotation.swift
//  VTQuestAR
//
//  Created by zhennan on 2020/7/23.
//

import SwiftUI
import AVFoundation
import MapKit
import CoreLocation
//The class defines the image annotation variables.
class imageAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage?
    var id: UUID?
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.subtitle = nil
        self.image = nil
        self.id = nil
        
    }
}
