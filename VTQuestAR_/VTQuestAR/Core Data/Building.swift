//
//  Building.swift
//  VTQuest
//
//  Created by Zhennan Yao on 6/22/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import Foundation
import CoreData

/*
 🔴 Set Current Product Module:
    In xcdatamodeld editor, select Building and
    select Current Product Module from Module menu.
 🔴 Turn off Auto Code Generation:
    In xcdatamodeld editor, select Building and
    select Manual/None from Codegen menu.
*/

// ❎ CoreData Building entity public class
public class Building: NSManagedObject, Identifiable {
    
    @NSManaged public var abbreviation: String?
    @NSManaged public var category: String?
    @NSManaged public var name: String?
    @NSManaged public var des_cription: String?    // 🔴
    @NSManaged public var yearBuilt: Int            // Int type is defined as 64-bit Integer
    @NSManaged public var address: String?
    @NSManaged public var imageFilename: String?
    @NSManaged public var latitude: NSNumber?       // 🔴
    @NSManaged public var longitude: NSNumber?      // 🔴
}

/*
🔴
 'description' cannot be used as an attribute name because it conflicts with the NSObject method name.
 
 Swift type Double cannot be used for @NSManaged Core Data attributes because the type
 Double cannot be represented in Objective-C, which is internally used for Core Data.
 Therefore, we must use the Objective-C type NSNumber instead for latitude and longitude.
 */

extension Building {
    
    static func allBuildingsFetchRequest() -> NSFetchRequest<Building> {
        
        let request: NSFetchRequest<Building> = Building.fetchRequest() as! NSFetchRequest<Building>
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }

}
