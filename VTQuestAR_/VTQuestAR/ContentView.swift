//
//  ContentView.swift
//  UIDemo
//
//  Created by zhennan on 2020/5/26.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView {
            augmentedReality().tabItem{
                Image(systemName: "viewfinder")
                Text("AR")
            }
            Recognition().tabItem{
                Image(systemName: "camera")
                Text("Recognition")
            }
            VTDirections().tabItem{
                Image(systemName: "map")
                Text("Directions")
            }
            vtBuildings().tabItem{
                Image(systemName: "list.bullet.below.rectangle")
                Text("Buildings")
            }
            visitorNoteView().tabItem{
                Image(systemName: "square.and.pencil")
                Text("Notes")
            }
            
            
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
