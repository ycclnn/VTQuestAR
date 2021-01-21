//
//  BuildingsList.swift
//  VTQuestAR
//
//  Created by zhennan on 2020/7/22.
//

import SwiftUI

struct BuildingsList: View {
    
  
    @State var selected: Building?
    // ❎ CoreData managedObjectContext reference
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // ❎ CoreData FetchRequest returning all Building entities in the database
    @FetchRequest(fetchRequest: Building.allBuildingsFetchRequest()) var vtBuildings: FetchedResults<Building>
    
    @State private var showAlert = false
    
    var body: some View {
       
        List (vtBuildings, selection: self.$selected){ item in
//            ForEach(self.vtBuildings) { aBuilding in
                NavigationLink(destination: BuildingDetails(building: item)){
                    BuildingItem(building: item)
                    
//                }
            }
        }.onAppear() {
            
            self.selected = self.vtBuildings[0]
            
        }
        
        //.customNavigationViewStyle()
        
        
    }
}
