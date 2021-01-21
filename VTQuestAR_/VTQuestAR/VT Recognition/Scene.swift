
import SpriteKit
import ARKit
import SwiftUI
import UIKit
import Combine
import CoreData

//showpublisherAr will send out signal and notify receiver to show the detail view of a building upon tap on the green pins.
public let showPublisherAR = PassthroughSubject<Bool, Never>()
//This publisher basically helps to notify the building information overlay view to update the building information. When a new building is recognized by CoreML, the building info should be updated immediately.
public let buildingPublisherAR = PassthroughSubject<Building, Never>()
class Scene: SKScene {
    
    var tap = false
    override func didMove(to view: SKView) {
      
    }
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    //When a touch happens on SKScene
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //first make sure the touch location is a sknode(green pin)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let hit = nodes(at: location)
        if let node = hit.first {
            //send out the signal to show the detail info of the building which get tapped
            showPublisherAR.send(true)
            //send out the detail info of which the building get tapped
            buildingPublisherAR.send(searchDatabase(str: node.name!))

            
        }
    }
    
     
     
    
    
}
//search the database and find a building by its name, then return it
public func searchDatabase(str: String) -> Building {
   let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //The name of the building
    let query = str
    // Initialize the global variable declared in BuildingData.swift
    // ❎ Define the fetch request
    let fetchRequest = NSFetchRequest<Building>(entityName: "Building")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    // Building name contains queryTrimmed in case insensitive manner
    fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", query)
    
    do {
        // ❎ Execute the fetch request
        //Single only single building is needed, we only retrieve the first element and there has to be only one element.
        buildingRecognized = try managedObjectContext.fetch(fetchRequest)[0]
        
    } catch {
        print("Fetch Request Failed!")
    }
    //return the single building recognized by ML model.
    return buildingRecognized
}
