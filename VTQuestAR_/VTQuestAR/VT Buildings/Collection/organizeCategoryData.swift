//
//  buildingModelView.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/2.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import CoreData


var academic = [Building]()
var support = [Building]()
var residentDining = [Building]()
var administration = [Building]()
var athletic = [Building]()
var dining = [Building]()
var research = [Building]()
var resident = [Building]()

var buildingListWithCategories: [String: [Building]] = [:]

//this method will load buildings into its corresponding types arrays.
public func organizeCategorys() {
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // ❎ Define the fetch request
    let fetchRequest = NSFetchRequest<Building>(entityName: "Building")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    var vtBuildings = [Building]()
    do {
        // ❎ Execute the fetch request
        vtBuildings = try managedObjectContext.fetch(fetchRequest)
        
    } catch {
        print("Fetch Database Failed!")
        return
    }
    
    for aBuilding in vtBuildings {
        switch aBuilding.category {
        case "Academic":
            academic.append(aBuilding)
        case "Support":
            support.append(aBuilding)
        case "Residence and Dining Halls":
            residentDining.append(aBuilding)
        case "Administration":
            administration.append(aBuilding)
        case "Athletic":
            athletic.append(aBuilding)
        case "Dining":
            dining.append(aBuilding)
        case "Research":
            research.append(aBuilding)
        case "Residence":
            resident.append(aBuilding)
        default:
            print("error")
        }
        
    }
    
    buildingListWithCategories["Academic"]  = academic
    buildingListWithCategories["Support"]  = support
    buildingListWithCategories["Residence and Dining Halls"]  = residentDining
    buildingListWithCategories["Administration"]  = administration
    buildingListWithCategories["Athletic"]  = athletic
    buildingListWithCategories["Dining"]  = dining
    buildingListWithCategories["Research"]  = research
    buildingListWithCategories["Residence"]  = resident

    
}
