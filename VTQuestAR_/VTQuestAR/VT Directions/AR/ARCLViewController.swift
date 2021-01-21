//
//  ARNavigation.swift
//  UIDemo
//
//  Created by zhennan on 2020/5/30.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import SpriteKit
import CoreLocation
import MapboxDirections
import ARCL
import MapKit
import ARKit
import Combine

let showARDirections = PassthroughSubject<Bool, Never>()

/// The ARCL view controller class that set up the route and present the route to users.
class ARCLViewController: UIViewController {
  
    /// Location manager
    let locationManager = CLLocationManager()
    
    /// Origin coordinate
    var from: CLLocationCoordinate2D
    
    /// Destination coordinate
    var to: CLLocationCoordinate2D
    
    /// Walking or driving
    var type: Int
    
    /// From user current location or from a campus building
    var originType: Int
    let sceneLocationView = SceneLocationView()
  
    init(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, type: Int, originType: Int) {
        self.from = from
        self.to = to
        self.type = type
        self.originType = originType
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //get user current location
    func getCurrentLocation() -> CLLocation? {
        var currentLoc = CLLocation()
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            if let location = locationManager.location {
                currentLoc = location
            } else {
                print("Unable to obtain user's current location")
            }
            
        }
        else {
            
        }
        locationManager.stopUpdatingLocation()
        return currentLoc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sceneLocationView)
        sceneLocationView.frame = view.bounds
        
       
    }
    func run() {
        
        navigate(from: self.from, to: self.to, type: self.type, originType: self.originType)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
    }
    //wrap up and prepare all parameters to present the navigation
    func navigate(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, type transportType: Int, originType originTypeSelection: Int) {
        let request = MKDirections.Request()
        var originPlaceMark: MKPlacemark
        if originTypeSelection == 0 {
            originPlaceMark = MKPlacemark(coordinate: getCurrentLocation()!.coordinate)
            request.source = MKMapItem(placemark: originPlaceMark)
        }
        if originTypeSelection == 1 {
            originPlaceMark = MKPlacemark(coordinate: origin)
            request.source = MKMapItem(placemark: originPlaceMark)
        }
        //set up destination placemark with coordinate
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        request.destination = destinationItem
        request.requestsAlternateRoutes = false
        if transportType == 0 {
            request.transportType = .walking
        }
        if transportType == 1 {
            request.transportType = .automobile
        }
        //get the mkdirection request
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if error != nil {
                return print("error when getting directions")
            }
            guard let response = response else {
                return print("no error, but no results either")
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                //show the successfully derived route if no error occurs
                self.show(routes: response.routes, originType: originTypeSelection)
            }
        }
        
    }

    func show(routes: [MKRoute], originType originTypeSelection: Int) {
      
        if originTypeSelection == 0 {
            guard let location = getCurrentLocation(),
                  location.horizontalAccuracy < 100 else {
                return DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    //if accuracy isn't good enough, wait 0.5 second and try again
                    self?.show(routes: routes, originType: 0)
                }
            }
        }
        //if user's current location is too far away from the AR navigation origin, then present this alert.
        //The reason is that the AR navigation requires users to be close to the augmented path, if they are too far away, they can barely see the path on the screen (too thin).
        if (getCurrentLocation()?.distance(from: CLLocation(latitude: self.from.latitude, longitude: self.from.longitude)))! > 100 {
            let alert = UIAlertController(title: "Too far away", message: "You are too far away from the route to see it in AR, try to move closer", preferredStyle: .alert)

           
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                //dismiss
                showARDirections.send(false)
            }
            ))

            self.present(alert, animated: true)
            
            
            return
        }
        
        guard (sceneLocationView.sceneLocationManager.currentLocation?.altitude) != nil else {
            //return assertionFailure("we don't have an elevation")
            let alert = UIAlertController(title: "Initialization failed", message: "Could not get current elevation of user location, please try again", preferredStyle: .alert)

           
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                //dismiss
                showARDirections.send(false)
            }
            ))

            self.present(alert, animated: true)
            return
        }
      
        //Show route by MKDirections in Augmented reality
        self.sceneLocationView.addRoutes(routes: routes)

    }
}


