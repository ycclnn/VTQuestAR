//
//  getDirection.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/11.
//  Copyright © 2020 zhennan yao. All rights reserved.
//
import SwiftUI
import CoreLocation
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapKit

/// This is the view that user will be redirected to when right up arrow button is tapped. User can choose origin, destination, transport type, map type(2D or AR).
struct getDirection: View {
//    @State var showAlert = false
   
    
    /// set hide nav bar to false when this view is loaded.
    @Binding var hidden: Bool
    
    /// for dismissing purpose
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    /// Index of origin selected
    @State var originSelected = 0
    
    /// index of destination selected
    @State var destinationSelected = 0
    
    /// transport tool currently selected
    @State var toolSelected = 0
    
    /// transport tool options
    let navigationTool = ["Walking", "Driving"]
    
    /// map type selected
    @State var mapTypeSelected = 0
    
    /// map type options
    let navigationMapType = ["2D Map", "AR Map"]
    
    /// origin types: current location or a building
    var fromWhereOptions = ["From Current Location", "From a Building"]
    
    /// selected origin type
    @State private var selectedFromWhereIndex = 0
    
    
    /// Route for mapbox api
    @State var directionsRoute: Route?
    
    /// Whether or not to show the 2d direction by Mapbox api
    @State var show = false
    
    /// mapbox api route options
    @State var options: RouteOptions?
    
    /// show/hide the AR direction
    @State var showAR = false
    
    /// The latitude of origin
    @State var fromLat: Double?
    
    /// The longitude of origin
    @State var fromLong: Double?
    
    /// The latitude of destination
    @State var toLat: Double?
    
    /// The longitude of destination
    @State var toLong: Double?
    

    var body: some View {
       
            Form {
                
                Section(header: Text("Select From Where")) {
                    HStack {
                        Spacer()
                        Picker("From Where", selection: $selectedFromWhereIndex) {
                            ForEach(0 ..< fromWhereOptions.count) { index in
                                Text(self.fromWhereOptions[index]).tag(index)
                            }
                        }
                        .frame(minWidth: 300, maxWidth: 500, alignment: .center)
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        Spacer()
                    }
                    
                }
                if selectedFromWhereIndex == 1 {
                    Section(header: Text("Select Building From")) {
                        Picker("From:", selection: $originSelected) {
                            ForEach(0 ..< vtBuildingNames.count, id: \.self) {
                                Text(vtBuildingNames[$0]).tag($0)
                            }
                        }
                        
                    }
                }
                Section(header: Text("Navigate To")) {
                    Picker("To:", selection: $destinationSelected) {
                        ForEach(0 ..< vtBuildingNames.count, id: \.self) {
                            Text(vtBuildingNames[$0]).tag($0)
                        }
                    }
                }
                Section(header: Text("Select Directions Transport Type")) {
                    transportTypePicker
                }
                Section(header: Text("Select Map Type")) {
                    mapTypePicker
                }
                Section(header: Text("Show Directions on Map")) {
                    //2D map
                    if (self.mapTypeSelected == 0) {
                        Button(action: {
                            self.calculateRoute()

                        }) {
                            HStack {
                                Image(systemName: "arrow.swap")
                                Text("Show")
                            }
                        }

                        
                    }
                    //Augmented reality map
                    else {
                            if selectedFromWhereIndex == 0 {
                            Button(action: {
                                self.showAR = true
                                self.fromLat = currentLocation().latitude
                                self.fromLong = currentLocation().longitude
                                self.toLat = (searchDatabase(str: vtBuildingNames[self.destinationSelected]).latitude as! Double)
                                self.toLong = (searchDatabase(str: vtBuildingNames[self.destinationSelected]).longitude as! Double)
                               
                                
                            }) {
                                HStack {
                                    Image(systemName: "arrow.swap")
                                    Text("Show")
                                }
                            }
                            }
                           

                            else {
                                Button(action: {
                                    self.showAR = true
                                    self.fromLat = (searchDatabase(str: vtBuildingNames[self.originSelected]).latitude as! Double)
                                    self.fromLong = (searchDatabase(str: vtBuildingNames[self.originSelected]).longitude as! Double)
                                    self.toLat = (searchDatabase(str: vtBuildingNames[self.destinationSelected]).latitude as! Double)
                                    self.toLong = (searchDatabase(str: vtBuildingNames[self.destinationSelected]).longitude as! Double)
                                   
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.swap")
                                        Text("Show")
                                    }
                                }
                            }

                    }
                }
                
            }
            // End of Form
                .navigationBarTitle("Get Directions",displayMode: .inline)
             
                
            .onAppear {
                self.hidden = false
            }
            .onReceive(showARDirections, perform: { (output: Bool) in
               
                self.showAR = output
            })
         
            //show 2D direction route
            .sheet(isPresented: self.$show) {
                twoDNavigation(directionsRoute: self.$directionsRoute, options: self.$options, showNavigation: self.$show, startFromCurrentLoc: self.$selectedFromWhereIndex)
                //Text("sb")
            //show AR direction route
            }
            .background(EmptyView().sheet(isPresented: self.$showAR) {

                ARCLViewControllerRepresentable(fromLat: self.$fromLat, fromLong: self.$fromLong, toLat: self.$toLat, toLong: self.$toLong, type: self.$toolSelected, originType: self.$selectedFromWhereIndex)

            })
            
        
    }
    //Get CLcoordinate2D by longitude and latitude
    func getCoordinate(lat: Double, long: Double) -> CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake(lat, long)
        
    }
    //Calculate the route for 2D map using Mapbox API
    func calculateRoute() {
        var originSelected = CLLocationCoordinate2D(latitude: 37.229695, longitude: -80.424279)
        if selectedFromWhereIndex == 0 {
            originSelected = currentLocation()
        }
        if selectedFromWhereIndex == 1 {
            
            
            let buildingSelected = vtBuildingNames[self.originSelected]
            let buildingLat = searchDatabase(str: buildingSelected).latitude
            let buildingLong = searchDatabase(str: buildingSelected).longitude
            originSelected = CLLocationCoordinate2DMake(buildingLat as! CLLocationDegrees, buildingLong as! CLLocationDegrees)
            
            
        }
        
        let destinationbuildingSelected = vtBuildingNames[self.destinationSelected]
        let destinationbuildingLat = searchDatabase(str: destinationbuildingSelected).latitude
        let destinationbuildingLong = searchDatabase(str: destinationbuildingSelected).longitude
        let destinationSelected = CLLocationCoordinate2DMake(destinationbuildingLat as! CLLocationDegrees, destinationbuildingLong as! CLLocationDegrees)
        
      
        let origin = Waypoint(coordinate: originSelected, name: "origin")
        let destination = Waypoint(coordinate: destinationSelected, name: "destination")

        
        var type = DirectionsProfileIdentifier.walking
        if (self.navigationTool[self.toolSelected] == "Driving") {
            type = DirectionsProfileIdentifier.automobileAvoidingTraffic
        }
        // Set options
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: type)
        self.options = options
        
        // Request a route using MapboxDirections.swift
        Directions.shared.calculate(options) { (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let route = response.routes?.first else {
                    return
                }
                
                self.directionsRoute = route
                self.show = true
                
            }
        }
    }
    //Transport type picker
    var transportTypePicker: some View {
           Picker("Transport Type", selection: $toolSelected) {
               ForEach(0 ..< navigationTool.count) { index in
                   Text(self.navigationTool[index]).tag(index)
               }
           }
           .pickerStyle(SegmentedPickerStyle())
           .padding(.horizontal)
       }
    //map type picker
    var mapTypePicker: some View {
        Picker("Select Map Type", selection: $mapTypeSelected) {
            ForEach(0 ..< navigationMapType.count) { index in
                Text(self.navigationMapType[index]).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
}

//struct NavigationButton<Destination: View, Label: View>: View {
//    var action: () -> Void = { }
//    var destination: () -> Destination
//    var label: () -> Label
//
//    @State private var isActive: Bool = false
//
//    var body: some View {
//        Button(action: {
//            self.action()
//            self.isActive.toggle()
//        }) {
//            self.label()
//              .background(
//                ScrollView { // Fixes a bug where the navigation bar may become hidden on the pushed view
//                    NavigationLink(destination: LazyDestination { self.destination() },
//                                                 isActive: self.$isActive) { EmptyView() }
//                }
//              )
//        }
//    }
//}
//struct LazyDestination<Destination: View>: View {
//    var destination: () -> Destination
//    var body: some View {
//        self.destination()
//    }
//}

                        
