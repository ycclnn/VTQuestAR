//
//  SearchResultsList.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/22/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import SwiftUI

struct SearchResultsList: View {
    
    var body: some View {
        List {
            ForEach(foundBuildingsList) { aBuilding in
                NavigationLink(destination: BuildingDetails(building: aBuilding)) {
                    BuildingItem(building: aBuilding)
                }
            }
        }   // End of List
            .navigationBarTitle(Text("Found Buildings"), displayMode: .inline)
    }
}

struct SearchResultsList_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsList()
    }
}
