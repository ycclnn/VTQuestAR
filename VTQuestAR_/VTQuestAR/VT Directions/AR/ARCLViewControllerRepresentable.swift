//
//  ARCLViewControllerRepresentable.swift
//  VTQuestAR
//
//  Created by zhennan on 2020/7/22.
//

import SwiftUI
import SpriteKit
import CoreLocation
import MapboxDirections
import ARCL
import MapKit
import ARKit

// This view show the navigation by utilizing the open source library: ARCL which combines the corelocation and the arkit.
struct ARCLViewControllerRepresentable: UIViewControllerRepresentable {
    /// Origin latitude
    @Binding var fromLat: Double?
    
    /// origin longitude
    @Binding var fromLong: Double?
    
    /// destination latitude
    @Binding var toLat: Double?
    
    /// destination longitude
    @Binding var toLong: Double?
    
    /// Walking or driving
    @Binding var type: Int
 
    /// From current location or from a campus building as origin
    @Binding var originType: Int
    func makeUIViewController(context: Context) -> ARCLViewController {
        let fromCoordinate = CLLocationCoordinate2DMake(fromLat!, fromLong!)
        let toCoordinate = CLLocationCoordinate2DMake(toLat!, toLong!)
        let vc = ARCLViewController(from: fromCoordinate, to: toCoordinate, type: self.type, originType: self.originType)
        vc.run()
        return vc
    }
    func updateUIViewController(_ uiViewController: ARCLViewController, context: Context) {
        
    }
}
