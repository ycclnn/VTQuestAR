//
//  buildingOverlay.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/17.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI

//the building overlay view for ML mode
struct mlBuildingOverlay: View {
   
    @State var show = false
    @State var building : Building?
    @State private var selectedMapTypeIndex = 0
    var mapTypes = ["Standard", "Satellite", "Hybrid"]
    
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                
                Form {
                   
                    
                    Section(header: Text("Building Name")) {
                        if self.building != nil {
                            Text(String(self.building!.name!))
                        }
                        else {
                            Text("")
                        }
                    }
                    Section(header: Text("Building Photo")) {
                        if self.building != nil {
                            Image(self.building!.imageFilename ?? "")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(minWidth: 0, maxWidth: geometry.size.width*0.8, alignment: .center)
                        }
                        else {
                            Image("imageUnavailable")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(minWidth: 0, maxWidth: geometry.size.width*0.8, alignment: .center)
                        }
                        
                    }
                    Section(header: Text("Building Name Abbreviation")) {
                        if self.building != nil {
                            Text(String(self.building!.abbreviation!))
                        }
                        else {
                            Text("")
                        }
                        
                    }
                    Section(header: Text("Building Category")) {
                        
                        if self.building != nil {
                            Text(String(self.building!.category!))
                        }
                        else {
                            Text("")
                        }
                        
                    }
                    Section(header: Text("Year Building Built")) {
                        
                        if self.building != nil {
                            Text(String(self.building!.yearBuilt))
                        }
                        else {
                            Text("")
                        }
                        
                    }
                    Section(header: Text("Select Map Type")) {
                        
                        Picker("Select Map Type", selection: self.$selectedMapTypeIndex) {
                            ForEach(0 ..< self.mapTypes.count) { index in
                                Text(self.mapTypes[index]).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        if self.building != nil {
                            NavigationLink(destination: buildingMap(index: self.$selectedMapTypeIndex, building: self.building!)
                                
                                
                            ) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("Show on Map")
                                }
                            }
                        }
                        else {
                            NavigationLink(destination: EmptyView()
                                
                                
                            ) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("Show on Map")
                                }
                            }
                        }
                    }
                    Section(header: Text("Building Description")) {
                       
                            if self.building != nil {
                                Text(String(self.building!.des_cription!))
                            }
                            else {
                                Text("")
                            }
                        
                    }
                    Section(header: Text("Building Address")) {
                        if self.building != nil {
                            Text(String(self.building!.address!))
                        }
                        else {
                            Text("")
                        }
                        
                    }
                        
                        
                    .font(.system(size: 14))
                    // }
                }.navigationBarTitle("Building Detail", displayMode: .inline)
                    .navigationBarHidden(false)
            }.frame(width: geometry.size.width*0.8, height: geometry.size.height * 0.7).position(.init(x: geometry.size.width / 2, y: geometry.size.height / 2))
            // End of Form
        
        }.opacity(self.show == true ? 1 : 0).onReceive(showPublisher, perform: { (output: Bool) in
            // Whenever publisher sends new value, replace current state var "show" to show/hide the building overlay
            self.show = output
        }).onReceive(buildingPublisher, perform: { (output: Building) in
            // Whenever publisher sends new value, replace current state var "building" to display corresponding building detail.
            self.building = output
        })
        
     
        
    }
    
}
