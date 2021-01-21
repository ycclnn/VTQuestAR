//
//  BuildingDetails.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/22/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import SwiftUI
import MapKit

/// The detail of a building view
struct BuildingDetails: View {
   
    @State var showSplitView: Bool?
    // Input Parameter
    let building: Building
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    //selected map type index
    @State private var selectedMapTypeIndex = 0
    //map type options
    var mapTypes = ["Standard", "Satellite", "Hybrid"]
    
    var body: some View {
        ZStack {
        Form {

            Section(header: Text("Building Name")) {
                Text(building.name ?? "")
            }
            Section(header: Text("Building Photo")) {
                HStack {
                    Spacer()
                    VStack {
                Image(building.imageFilename ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 300, maxWidth: 500, alignment: .center)
                        
                    }
                    Spacer()
                }
            }
            Section(header: Text("Building Name Abbreviation")) {
                Text(building.abbreviation ?? "")
            }
            Section(header: Text("Building Category")) {
                Text(building.category ?? "")
            }
            Section(header: Text("Year Building Built")) {
                Text(String(building.yearBuilt))
            }
            Section(header: Text("Select Map Type")) {
                
                Picker("Select Map Type", selection: $selectedMapTypeIndex) {
                   ForEach(0 ..< mapTypes.count) { index in
                       Text(self.mapTypes[index]).tag(index)
                   }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
//
                NavigationLink(destination: buildingMap(index: self.$selectedMapTypeIndex, building: self.building)
    
                ) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Show on Map")
                    }
                }
            }
            Section(header: Text("Building Description")) {
                Text(building.des_cription ?? "")
            }
            Section(header: Text("Building Address")) {
                Text(building.address ?? "")
            }

            }
            
            // End of Form
            
            .font(.system(size: 14))
            .navigationBarTitle("Building Detail", displayMode: .inline)
        
            .navigationBarHidden(false)
        }
        
        
       
    }
    


}


/// Return different map view according to map type.
struct buildingMap: View {
    
    
    
    @Binding var index : Int
    let building: Building
    
    
    var body: some View {
        //standard map view
        if (index == 0) {
            return MapView(mapType: MKMapType.standard, latitude: building.latitude as! Double, longitude: building.longitude as! Double, delta: 1000.0, deltaUnit: "meters", annotationTitle: building.name ?? "", annotationSubtitle: building.category ?? "")
            .navigationBarTitle(Text(building.name ?? ""), displayMode: .inline)
                .edgesIgnoringSafeArea(.all)

        }
        //satellite map view
        else if (index == 1) {
           return MapView(mapType: MKMapType.satellite, latitude: building.latitude as! Double, longitude: building.longitude as! Double, delta: 1000.0, deltaUnit: "meters", annotationTitle: building.name ?? "", annotationSubtitle: building.category ?? "")
            .navigationBarTitle(Text(building.name ?? ""), displayMode: .inline)
            .edgesIgnoringSafeArea(.all)

        }
        //hybrid map view
        else {
           return MapView(mapType: MKMapType.hybrid, latitude: building.latitude as! Double, longitude: building.longitude as! Double, delta: 1000.0, deltaUnit: "meters", annotationTitle: building.name ?? "", annotationSubtitle: building.category ?? "")
            .navigationBarTitle(Text(building.name ?? ""), displayMode: .inline)
            .edgesIgnoringSafeArea(.all)
 
        }
        
        
    }
    
}
