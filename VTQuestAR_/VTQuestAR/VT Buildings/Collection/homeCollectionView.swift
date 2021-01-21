//
//  homeCollectionView.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/3.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI

struct homeCollectionView: View {
    //@State var selected : Building
    //each section is a building category
    @State var section :Int
    //show all buildings in certain category
    @State var showSeeAll = false
    //show a single building detail view
    @State var showSingleBuilding = false
    
    @State var defaultMapIndex = 0
    var body: some View {
        buildingCollectionView(showSeeAll: self.$showSeeAll, showSingleBuilding: self.$showSingleBuilding).edgesIgnoringSafeArea(.all)
            .navigationBarTitle("").navigationBarHidden(true)
            //receive the publisher signal when user
            .onReceive(sectionSender, perform: { (output: Int) in
                if (output != -1) {
                self.showSeeAll = true
                }
                

            }).sheet(isPresented: self.$showSeeAll) {
                seeAll(section: sectionSender.value)
                
            }
            .background(
                //when a single building item is tapped, display its detail page
                EmptyView().sheet(isPresented: self.$showSingleBuilding) {
                NavigationView {
                    ZStack {
                        BuildingDetails(building: buildingSender)
                    }
                   
                }
                }).onDisappear() {
                    sectionSender.send(-1)
                    showSeeAll = false
                }

            
        
    }
    
}

//when see all button is tapped, display all buildings
struct seeAll: View {
    @State var section: Int
    
    var body: some View {
        NavigationView {
            ZStack {
            List{
                ForEach(buildingListWithCategories[categories[self.section]]!) { aBuilding in
                    NavigationLink(destination: BuildingDetails(building: aBuilding)){
                        BuildingItem(building: aBuilding)
                        
                    }
                }
            }.navigationBarTitle(Text(categories[self.section]), displayMode: .inline)
            }
            BuildingDetails(building: buildingListWithCategories[categories[self.section]]![0])
        }.customNavigationViewStyle()
    }
}

