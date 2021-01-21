//
//  AppDelegate.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/22/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

/*
The symbol ❎ identifies code related to CoreData
The symbol 🔴 alerts you to something extremely important
*/

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var polygon = GMSPolygon()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //initialze Google Api keys
        GMSServices.provideAPIKey("GET YOUR OWN KEY")
        GMSPlacesClient.provideAPIKey("GET YOUR OWN KEY")
        
        //create a polygon that cover vt campus area, will be used to check if user's inside the campus or not
        let rect = GMSMutablePath()
        rect.add(CLLocationCoordinate2D(latitude: 37.22629, longitude: -80.41062))
        rect.add(CLLocationCoordinate2D(latitude: 37.19767399457562, longitude: -80.40788081172084))
        rect.add(CLLocationCoordinate2D(latitude: 37.20987251730094, longitude: -80.42771060553822))
        rect.add(CLLocationCoordinate2D(latitude: 37.22408959353001, longitude: -80.44007022467885))
        rect.add(CLLocationCoordinate2D(latitude: 37.24185717066667, longitude: -80.43577869025502))
        rect.add(CLLocationCoordinate2D(latitude: 37.24864753875293, longitude: -80.42894825739785))
        rect.add(CLLocationCoordinate2D(latitude: 37.22630272811946, longitude: -80.41052414454107))
        // Create the polygon, and assign it to the map.
        self.polygon = GMSPolygon(path: rect)
        /*
        ************************************
        *   Create VT Buildings Database   *
        ************************************
        */
        createVTBuildingsDatabase()      // Given in BuildingData.swift
        
        
        organizeCategorys()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    /*
     --------------------------------------------------
     MARK: - ❎ Core Data Persistent Container Creation
     --------------------------------------------------
     */

    /*
     The following instance variable is declared with the lazy attribute, i.e., lazy var,
     which is called a Lazy Stored Property, commonly referred to as lazy initialization,
     lazy instantiation, or lazy loading. This is a technique by which the creation of an
     object or a demanding process is delayed until it is really needed. This is helpful
     to better manage the efficient use of system resources.
     
     "Lazy properties are useful when the initial value for a property is dependent on
     outside factors whose values are not known until after an instance's initialization
     is complete. Lazy properties are also useful when the initial value for a property
     requires complex or computationally expensive setup that should not be performed
     unless or until it is needed." [Apple]
     */
    lazy var persistentContainer: NSPersistentContainer = {
        //-----------------------------------------------------------------
        // This is a Closure (block of code like a function) used to return
        // the initial value of the persistentContainer instance variable.
        //-----------------------------------------------------------------
        /*
         Instantiate an object from the NSPersistentContainer class, initialize it with
         the application name, and store its object reference into local constant 'container'
        */
        let container = NSPersistentContainer(name: "VTQuestAR")
        
        
        
        //
        
        /*
         Invoke container's instance method loadPersistentStores() to load the persistent stores.
         */
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 - The parent directory does not exist, cannot be created, or disallows writing.
                 - The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 - The device is out of space.
                 - The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // Return the object reference of the newly created NSPersistentContainer object
        return container
    }()
    
    /*
     ----------------------------------
     MARK: - ❎ CoreData Save Operation
     ----------------------------------
     */
    func saveContext () {
        /*
         persistentContainer's viewContext instance property holds
         the object reference of the NSManagedObjectContext
         */
        let managedObjectContext: NSManagedObjectContext = persistentContainer.viewContext
        
        // Check to see if managedObjectContext has any changes
        if managedObjectContext.hasChanges {
            do {
                // Try to save the changes
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
   

}

extension GMSPolygon {
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        
        if self.path != nil {
            if GMSGeometryContainsLocation(coordinate, self.path!, true) {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
}
