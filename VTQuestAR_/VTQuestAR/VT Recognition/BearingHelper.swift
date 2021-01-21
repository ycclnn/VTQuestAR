//
//  MatrixHelper.swift
//  firstdemo
//
//  Created by zhennan on 2020/3/29.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import Foundation
import GLKit
import CoreLocation
//These helper functions involving mathematical calculations to help display green pins in AR with correct position.
struct BearingHelper {
    //Reference: https://medium.com/@yatchoi/getting-started-with-arkit-real-life-waypoints-1707e3cb1da2
    static func calculateBearing(startLocation: CLLocation, endLocation: CLLocation) -> Float {
        var azimuth: Float = 0
        let lat1 = GLKMathDegreesToRadians(Float(startLocation.coordinate.latitude))
        let lon1 = GLKMathDegreesToRadians(Float(startLocation.coordinate.longitude))
        let lat2 = GLKMathDegreesToRadians(Float(endLocation.coordinate.latitude))
        let lon2 = GLKMathDegreesToRadians(Float(endLocation.coordinate.longitude))
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        azimuth = GLKMathRadiansToDegrees(Float(radiansBearing))
        if (azimuth < 0) { azimuth += 360 }
        return azimuth
    }
}

