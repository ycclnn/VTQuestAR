//
//  Photo.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/1.
//  Copyright © 2020 zhennan yao. All rights reserved.
//
import Foundation
import CoreData
 

// ❎ CoreData photoAndAudio entity public class
public class PhotoAndAudio: NSManagedObject, Identifiable {
 
    @NSManaged public var photo: Data?
    @NSManaged public var audio: Data?
    @NSManaged public var note: Note?
}

 
