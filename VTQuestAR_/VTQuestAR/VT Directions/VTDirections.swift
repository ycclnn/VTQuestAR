//
//  Navigation.swift
//  UIDemo
//
//  Created by zhennan on 2020/5/27.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import MapKit
struct VTDirections: View {
    
    /// Control hide/show the nav bar for parent and child views.
    @State var hideNavBar = true
    
    /// Show/hide the bottom sheet that switch among three different map types.
    @State private var bottomSheetShown = false
    
    /// Instance of location manager
    @ObservedObject var locationManager = VTDirectionLocationManager()
    
    /// Current map type
    @State var selectedMapTypeIndex = 0

    
    /// Three types of map
    var mapTypes = ["Standard", "Satellite", "Hybrid"]
    
    
    /// Will be toggled when user taps the update button
    @State private var updateCurrentLocation = false
    
    
    var body: some View {
        NavigationView {
            ZStack {
                currentMap.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Button(action: {
                                //toggle to show the bottom sheet
                                self.bottomSheetShown.toggle()
                            }) {
                                Image(systemName: self.bottomSheetShown ? "info.circle.fill" : "info.circle")
                                    
                                    .font(Font.title.weight(.light))
                                    .foregroundColor(.blue)
                                    .padding(.top, 10)
                                    .padding(.bottom, 7)
                            }
                            Divider()
                            //tap to get directions from current location/a building to another building by AR/2D map.
                            NavigationLink(destination: getDirection(hidden: self.$hideNavBar)) {
                                Image(systemName: "arrow.up.right.diamond")
                                 
                                    .font(Font.title.weight(.light))
                                    .foregroundColor(.blue)
                                    .padding(.top, 4)
                                    .padding(.bottom, 4)
                            }
                            
                            Divider()
                            
                            Button(action: {
                                //start/stop updating user's current location
                                if (self.updateCurrentLocation == false) {
                                    updateLoc = true
                                    self.locationManager.locationManager.startUpdatingLocation()
                                    
                                }
                                if (self.updateCurrentLocation == true) {
                                    updateLoc = false
                                    self.locationManager.locationManager.stopUpdatingLocation()
                                }
                                self.updateCurrentLocation.toggle()
                                
                            }) {
                                Image(systemName: self.updateCurrentLocation ? "location.fill" : "location")
                               
                                  
                                    .font(Font.title.weight(.light))
                                    .foregroundColor(.blue)
                                    .padding(.top, 7)
                                    .padding(.bottom, 10)
                            }
                        }
                        .frame(width: 40, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                        ).padding()
                    }
                    Spacer()
                }
                .padding(.bottom, 35)
                //show the customized sheet to change map type
                if (self.bottomSheetShown) {
                    //user geometry reader to yield corrrect UI constraints.
                    GeometryReader { geometry in
                        BottomSheetView(
                            isOpen: self.$bottomSheetShown,
                            maxHeight: geometry.size.height * 0.32
                        ) {
                            // Color.blue
                            Divider()
                            Section(header: Text("Select Map Type").foregroundColor(Color.blue).bold().padding(.top, 10).padding(.bottom, 10)) {
                                Picker("Select Map Type", selection: self.$selectedMapTypeIndex) {
                                    ForEach(0 ..< self.mapTypes.count) { index in
                                        Text(self.mapTypes[index]).tag(index)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.leading, 15).padding(.trailing, 15)
                            }.padding(.top, 10)
                            
                        }.edgesIgnoringSafeArea(.all)
                        
                    }
                }
            }
            .navigationBarHidden(self.hideNavBar)
            .navigationBarTitle("")
            .onAppear {
                //hide nav bar (make the map view whole screen ignoring safe areas)
                self.hideNavBar = true
                //start the location manager service
                self.locationManager.locationManager.startUpdatingLocation()
              
                
            }.onDisappear() {
                //stop the location manager service
                self.locationManager.locationManager.stopUpdatingLocation()
              
            }
            
        }.navigationViewStyle(StackNavigationViewStyle())
        
        
        
        
    }
    //vt Campus map
    var currentMap: some View {
        
        var mapType: MKMapType
        
        switch selectedMapTypeIndex {
        case 0:
            mapType = MKMapType.standard
        case 1:
            mapType = MKMapType.satellite
        case 2:
            mapType = MKMapType.hybrid
        default:
            fatalError("Map type is out of range!")
        }
        
        
        return AnyView(
            MapView(mapType: mapType, latitude: (self.locationManager.lastLocationD?.coordinate.latitude)!, longitude:(self.locationManager.lastLocationD?.coordinate.longitude)!,
                    delta: 1000.0, deltaUnit: "meters", annotationTitle: "Your current location",
                    annotationSubtitle: "Go Hokies!")
        )
        
        
    }
}
