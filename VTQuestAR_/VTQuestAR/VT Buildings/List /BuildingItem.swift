//
//  BuildingItem.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/22/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import SwiftUI

struct BuildingItem: View {
    
    // Input Parameter
    let building: Building
    
    var body: some View {
        HStack {
            
            Image(building.imageFilename ?? "")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100.0)
                
            
            VStack(alignment: .leading) {
                Text(building.name ?? "")
                Text(building.category ?? "")
                Text(String(building.yearBuilt))
            }
            .font(.system(size: 14))
            
        }   // End of HStack
    }
}

