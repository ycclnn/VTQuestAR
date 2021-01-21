//
//  BuildingStruct.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/22/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import SwiftUI


/// The struct that holds the value of buildings.
struct BuildingStruct: Hashable, Codable, Identifiable {
    
    var id: Int
    var name: String
    var abbreviation: String
    var category: String
    var description: String
    var yearBuilt: Int
    var address: String
    var latitude: Double
    var longitude: Double
    var imageFilename: String
}

/// Make all the variables gettable.
protocol buildingProtocol: Codable, Hashable {
    var id: Int {get}
    var name: String {get}
    var abbreviation: String {get}
    var category: String {get}
    var description: String {get}
    var yearBuilt: Int {get}
    var address: String {get}
    var latitude: Double {get}
    var longitude: Double {get}
    var imageFilename: String {get}
}
