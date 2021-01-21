//
//  Note.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/1.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import CoreData
import Foundation

 
// ❎ CoreData Note entity public class
public class Note: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var noteTitle: String?
    @NSManaged public var noteDescription: String?
    @NSManaged public var dateVisited: String?
    //@NSManaged public var datetime: String?
    @NSManaged public var lat: NSNumber?
    @NSManaged public var long: NSNumber?
    //@NSManaged public var notes: String?
    @NSManaged public var rating: String?
    @NSManaged public var photoAndAudio: PhotoAndAudio?
}
 
extension Note {
    /*
     ❎ CoreData FetchRequest. calls this function
        to get all of the Note entities in the database
     */
    static func allNotessFetchRequest() -> NSFetchRequest<Note> {
       
        let request: NSFetchRequest<Note> = Note.fetchRequest() as! NSFetchRequest<Note>
        /*
         List the parks in alphabetical order with respect to note title
         */
        request.sortDescriptors = [
            // Primary sort key: noteTitle
            NSSortDescriptor(key: "noteTitle", ascending: true)
        ]
       
        return request
    }
}
 
