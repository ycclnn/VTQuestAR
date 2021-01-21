//
//  vtBuildings.swift
//  UIDemo
//
//  Created by zhennan on 2020/5/30.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import CoreData
import Foundation
import Combine

let pass = PassthroughSubject<Bool, Never>()

struct vtBuildings: View {
    
    /// Currently selected button
    @State var selected = "row"
    
    /// Show the alert message when questionmark button is tapped
    @State private var showAlert = false

    //@State private var willMoveToNextScreen = false
    var body : some View{
        
        NavigationView {
            ZStack {
                VStack(spacing: 0){
                    ZStack{
                        
                        HStack{
                            //database button to direct user to database page
                            Button(action: {
                                self.selected = "database"
                                
                            })
                            {
                                VStack {
                                    Image(systemName: "briefcase").font(.system(size: 19, weight: .regular))
                                        .foregroundColor(self.selected == "database" ? Color.blue : Color.black.opacity(0.2))
                                    
                                    Circle().fill(self.selected == "database" ? Color.blue : Color.clear).frame(width: 5, height: 5).padding(.vertical,4)
                                }
                            }
                            
                            
                            Spacer()
                            //show message to user that tells how many buildings are listed
                            if (selected != "database") {
                                Button(action: {
                                    
                                    self.showAlert = true
                                }) {
                                    VStack {
                                        Image(systemName: "questionmark.circle").font(.system(size: 19, weight: .regular)).foregroundColor(Color.black.opacity(0.2))
                                        Circle().fill(self.selected == "questionMark" ? Color.blue : Color.clear).frame(width: 5, height: 5).padding(.vertical,4)
                                    }
                                }
                            }
                            
                        }
                        
                        HStack(spacing: 15){
                            
                            //display the buildings in rows
                            Button(action: {
                                
                                self.selected = "row"
                                
                            }) {
                                
                                VStack{
                                    
                                    Image(systemName: "list.bullet").font(.system(size: 19, weight: .regular))
                                        .foregroundColor(self.selected == "row" ? Color.blue : Color.black.opacity(0.2))
                                    
                                    Circle().fill(self.selected == "row" ? Color.blue : Color.clear).frame(width: 5, height: 5).padding(.vertical,4)
                                }
                                
                            }
                            //display the buildings in collection cells
                            Button(action: {
                                
                                self.selected = "grid"
                                
                            }) {
                                
                                VStack{
                                    
                                    Image(systemName: "rectangle.grid.2x2").font(.system(size: 19, weight: .regular))
                                        .foregroundColor(self.selected == "grid" ? Color.blue : Color.black.opacity(0.2))
                                    
                                    
                                    Circle().fill(self.selected == "grid" ? Color.blue : Color.clear).frame(width: 5, height: 5).padding(.vertical,4)
                                }
                                
                                
                            }
                            //display the buildings in augmented reality
                            Button(action: {
                                
                                self.selected = "ar"
                                
                            }) {
                                
                                VStack(spacing: 5){
                                    
                                    Image(systemName: "a.circle").font(.system(size: 19, weight: .regular))
                                        .foregroundColor(self.selected == "ar" ? Color.blue : Color.black.opacity(0.2))
                                    
                                    
                                    
                                    Circle().fill(self.selected == "ar" ? Color.blue : Color.clear).frame(width: 5, height: 5).padding(.vertical, 4)
                                }
                                
                            }
                        }
                        
                        
                        
                    }.frame(height: 50)
                    .padding(.horizontal)
                    .padding(.top, 5)
                    Divider()
                    //if database button is selected, display searchDatabase() view
                    if (self.selected == "database") {
                        SearchDatabase()
                    }
                    //if ar button is selected, display arBuilding view
                    if (self.selected == "ar") {
                       
                        ZStack {
                            arBuildingRepresentable().edgesIgnoringSafeArea(.all)
                            arBuildingInfo()

                        }
                       
                     
                    }
                    //if row button is selected, display list view
                    if (self.selected == "row") {
                        
                        BuildingsList()
                        
                    }
                    //if grid button is selected, display buildings in grid view
                    if (self.selected == "grid") {
                        // GridView()
                        //selected: Building(),
                        homeCollectionView(section: -1)
                        
                    }
                    
                    
                }
                
                
            }.navigationBarTitle("").navigationBarHidden(true)
            //below are split default views for iPad, which won't show on iPhone
            if (self.selected == "row") {
                BuildingDetails(building: searchDatabase(str: "Agnew Hall"))
            }
            if (self.selected == "grid") {
                
                    List{
                        ForEach(buildingListWithCategories[categories[0]]!) { aBuilding in
                            NavigationLink(destination: BuildingDetails(building: aBuilding)){
                                BuildingItem(building: aBuilding)
                                
                            }
                        }
                    }.navigationBarTitle(Text(categories[0]), displayMode: .inline)
                
            }
            if (self.selected == "database") {
                ByName()
            }
            
        //alert messages
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Number of VT Buildings Listed"),
                  message: Text("A total of \(vtBuildingNames.count) buildings are listed. Tap a building to see its details."),
                  dismissButton: .default(Text("OK")))
        }
        //.customNavigationViewStyle()
        .navigationViewStyle(StackNavigationViewStyle())
        
        
    }
}




