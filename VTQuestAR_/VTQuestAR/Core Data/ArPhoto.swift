//
//  ArPhoto.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/7.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import CoreData
import Foundation

 
// ❎ CoreData ArPhoto entity public class
public class ArPhoto: NSManagedObject, Identifiable {
    //@NSManaged public var name: String?
    @NSManaged public var photos: Data?
    @NSManaged public var date: String?
    //@NSManaged public var title: String?
    @NSManaged public var lat: NSNumber?
    @NSManaged public var long: NSNumber?
}
 
extension ArPhoto {
    /*
     ❎ CoreData FetchRequest. calls this function
        to get all of the ArPhoto entities in the database
     */
    static func allPhotosFetchRequest() -> NSFetchRequest<ArPhoto> {
       
        let request: NSFetchRequest<ArPhoto> = ArPhoto.fetchRequest() as! NSFetchRequest<ArPhoto>
        /*
         List the parks in added time order.
         */
        request.sortDescriptors = []
       
        return request
    }
}
 
