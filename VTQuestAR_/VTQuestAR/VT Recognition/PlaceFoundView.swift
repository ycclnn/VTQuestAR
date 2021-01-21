//
//  PlaceFoundView.swift
//  UIDemo
//
//  Created by zhennan on 2020/5/27.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import CoreLocation
import Combine
//will notify the number of green pins near the user
let showPlacesCount = PassthroughSubject<Int, Never>()
struct PlaceFoundView: View {
    @State var buildingsFound = 0
    //@ObservedObject var locationM = LocationManager()
    var body: some View {
        HStack {
            Spacer()
           
            Text("\(self.buildingsFound) building(s) found").bold().foregroundColor(.white)
           
            Spacer()
            Button(action: {
               
                
                NotificationCenter.default.post(name: Notification.Name("shouldRemoveNodes"), object: nil)
                self.buildingsFound = 0
                
                setupRunAR()
                //self.locationM.locationManager.startUpdatingLocation()
            }) {
                Image(systemName: "arrow.counterclockwise.circle").font(.system(size: 19, weight: .regular))
            }
        }.padding(.trailing, 5).padding(.leading, 40).frame(height: 50).background(Color.black).opacity(0.7)
        .onReceive(showPlacesCount, perform: { (output: Int) in
            // Whenever publisher sends new value, old one to be replaced
            
          
            self.buildingsFound = output
            
        })
        .onAppear() {
            
            self.buildingsFound = insideCircle.count
            
        }
    }
}

func setupRunAR() {

    if currentLocationCL().horizontalAccuracy < 100 {
        insideCircle.removeAll()
       
       
            //let cl = CLLocation(latitude: 37.231193, longitude: -80.421608)
        
            //add all buildings that inside the circle of diameter of 100m to the array.
      
            for aBuilding in allBuildings {
                let buildingLocation = CLLocation(latitude: aBuilding.latitude as! CLLocationDegrees, longitude: aBuilding.longitude as! CLLocationDegrees)
                
                let distance = currentLocationCL().distance(from: buildingLocation)
               
                //add to the array if the radius is < 50m
                if (distance < 100) {
                  
                    insideCircle[aBuilding.name!] = buildingLocation
                }
            }
        showPlacesCount.send(insideCircle.count)
        runAR(currentLocationCL())
    }
}
