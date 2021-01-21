//
//  LocationManager.swift
//  UIDemo
//
//  Created by zhennan on 2020/5/28.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import Foundation
import CoreLocation
import Combine
import ARKit

/// All the building that inside a circle whose center is user's current location. For example, this array will include all buildings that inside a circle when users move around the campus with specified diameter.
var insideCircle = [String: CLLocation]()

/// The location manager class for VT recognition, AR tab view.
class VTRecognitionLocationManager: NSObject, ObservableObject {
    
    /// Send out the changes if needed.
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    /// Instance of location manager
    public let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        //The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        self.locationManager.distanceFilter = 1;
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
      
        if CLLocationManager.locationServicesEnabled() {
           
            // Set up locationManager
            //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            // Ask locationManager to obtain the user's current location coordinate
            if let location = locationManager.location {
                lastLocation = location
            } else {
                print("Unable to obtain user's current location")
            }
            
        } else {
            // Location Services turned off in Settings
        }
        locationManager.stopUpdatingLocation()
        
    }
    
    
    /// Last stored location, will notify the observers if the value has been changed.
    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }

    
}
extension VTRecognitionLocationManager: CLLocationManagerDelegate {
    //Asks the delegate whether the heading calibration alert should be displayed.
    func locationManagerShouldDisplayHeadingCalibration(_ _managr: CLLocationManager) -> Bool {
        return true
    }
    //capture the location service permission changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //self.locationStatus = status
        switch status {
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
                break
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                break
            case .authorizedAlways:
                locationManager.startUpdatingLocation()
                break
            case .restricted:
                break
            case .denied:
              
                break
            default:
                break
            }
    }


    
}
