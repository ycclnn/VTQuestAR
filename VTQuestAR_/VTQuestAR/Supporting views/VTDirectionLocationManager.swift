//
//  VTDirectionLocationManager.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/14.
//  Copyright © 2020 zhennan yao. All rights reserved.
//
import Foundation
import CoreLocation
import Combine


/// update the location or not, will be toggled whenever user want to start updating their location in VT Directions view.
var updateLoc = false
class VTDirectionLocationManager: NSObject, ObservableObject {
    
    ///Initialize a object passthrough subject to send out signals.
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    /// Instance of location manager.
    public let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        //The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        self.locationManager.distanceFilter = 1;
        
        
        self.locationManager.delegate = self
        //best accuracy
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //ask for permission
        self.locationManager.requestWhenInUseAuthorization()
        //if service is enable, start updating locations
        if CLLocationManager.locationServicesEnabled() {
            
            // Set up locationManager
            
            locationManager.startUpdatingLocation()
            
            // Ask locationManager to obtain the user's current location coordinate
            if let location = locationManager.location {
                //set the value of last detected location
                lastLocationD = location
            } else {
                print("Unable to obtain user's current location")
            }
            
        } else {
            exit(-1)
            // Location Services turned off in Settings
        }
        
        locationManager.stopUpdatingLocation()
        
    }
    
    
    /// The published var will notify all classes which observe this location manager class. Whenever the location changes, those class that subbscribe to this location manager will receice the changes immediately.
    @Published var lastLocationD: CLLocation? {
        willSet {
            //send out new value if the value of lastLocationD has been updated.
            objectWillChange.send()
        }
    }
    
}
extension VTDirectionLocationManager: CLLocationManagerDelegate {
    
    //Asks the delegate whether the heading calibration alert should be displayed
    func locationManagerShouldDisplayHeadingCalibration(_ _managr: CLLocationManager) -> Bool {
        return true
    }
    //monitor the changes of location service permission
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        //if the updateloc option is true, meaning user want the location to be updating, then update the last location and send out the location changes to its subscribers/observers.
        if updateLoc == true {
            self.lastLocationD = location
        }
        
    }
    
    
}
