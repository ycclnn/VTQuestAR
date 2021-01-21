//
//  BuildingData.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/23/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import SwiftUI
import CoreData

var allBuildings = [Building]()
// Global array of VT building names
var vtBuildingNames = [String]()

// Global array of VT building categories
var vtBuildingCategories = [String]()

// Global array of VT buildings found based on database search
var foundBuildingsList = [Building]()

fileprivate var buildingStructList = [BuildingStruct]()

/*
 ***********************************
 MARK: - Build VT Buildings Database
 ***********************************
 */
public func createVTBuildingsDatabase() {

    buildingStructList = loadFromMainBundle("BuildingData.json")
    
    var names = [String]()
    var categories = [String]()
    
    for aBuilding in buildingStructList {
        names.append(aBuilding.name)
        
        if !categories.contains(aBuilding.category) {
            categories.append(aBuilding.category)
        }
    }
    
    vtBuildingNames = names.sorted()
    vtBuildingCategories = categories.sorted()
    
    populateDatabase()
}

/*
*****************************************************************
MARK: - Load Building Data File from Main Bundle (Project Folder)
*****************************************************************
*/
public func loadFromMainBundle<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Unable to find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Unable to load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Unable to parse \(filename) as \(T.self):\n\(error)")
    }
}

/*
*********************************************
MARK: - Populate Database If Not Already Done
*********************************************
*/
func populateDatabase() {
    
    // ❎ Get object reference of CoreData managedObjectContext from the persistent container
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // ❎ Define the fetch request
    let fetchRequest = NSFetchRequest<Building>(entityName: "Building")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    var vtBuildings = [Building]()
    
    do {
        print("ext")
        // ❎ Execute the fetch request
        vtBuildings = try managedObjectContext.fetch(fetchRequest)
    } catch {
        print("Populate Database Failed!")
        return
    }
    
    if vtBuildings.count > 0 {
        allBuildings = vtBuildings
        // Database has already been populated
        print("Database has already been populated!")
        
        return
    }
    
    print("Database will be populated!")
    
    for aBuildingStruct in buildingStructList {
        /*
         =================================================
         Create a Building Entity instance and dress it up
         =================================================
         */
        // ❎ Create an instance of the Building Entity in CoreData managedObjectContext
        let buildingEntity = Building(context: managedObjectContext)
        
        // ❎ Dress it up by specifying its attributes
        buildingEntity.name = aBuildingStruct.name
        buildingEntity.abbreviation = aBuildingStruct.abbreviation
        buildingEntity.category = aBuildingStruct.category
        buildingEntity.des_cription = aBuildingStruct.description
        buildingEntity.yearBuilt = aBuildingStruct.yearBuilt
        buildingEntity.address = aBuildingStruct.address
        buildingEntity.latitude = aBuildingStruct.latitude as NSNumber
        buildingEntity.longitude = aBuildingStruct.longitude as NSNumber
        buildingEntity.imageFilename = aBuildingStruct.imageFilename
        
        /*
         ===================================================
         Save Building Entity instance to Core Data database
         ===================================================
         */
        
        // ❎ CoreData Save operation
        do {
            try managedObjectContext.save()
        } catch {
            return
        }
        
    }   // End of for loop
    
    //make sure the array: allBuildings have the building values
    populateDatabase()
    
}   // End of populateDatabase() function

