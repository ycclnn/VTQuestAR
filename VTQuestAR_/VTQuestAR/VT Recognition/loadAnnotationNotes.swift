
//
//  loadAnnotationNotes.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/19.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

struct loadAnnotationNotes {
    func getGreenPins(location: CLLocation, completion: @escaping (_ items:[[String: Any]]?, _ errorMsg:String?) -> Void) {
        var greenPinsReturned = [[String: Any]]()
        for item in insideCircle {

            let singlePin = [
                "name": "\(item.key)",
                "latitude": item.value.coordinate.latitude,
                "longitude": item.value.coordinate.longitude
                ] as [String: Any]

            greenPinsReturned.append(singlePin)
        }

        if (greenPinsReturned.count > 0) {
            completion(greenPinsReturned, nil)
        }
        else {
            completion(nil, "No buildings or green pins found near user's location")
        }

    }



}
