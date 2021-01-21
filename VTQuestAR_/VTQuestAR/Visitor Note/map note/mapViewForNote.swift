//
//  mapViewForNote.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/2.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import MapKit
import UIKit
import CoreLocation
import CoreData
import Combine
let mkMap = MKMapView(frame: .zero)
//Send a note to receiver
let noteDetailSender = PassthroughSubject<Note,Never>()
//decide show/hide a callout detail view
let showCalloutDetailSender = PassthroughSubject<Bool,Never>()
struct mapViewForNote: UIViewRepresentable {
    // ❎ Refresh this view upon notification that the managedObjectContext completed a save.
    // Upon refresh, @FetchRequest is re-executed fetching all Song entities with all the changes.
    @EnvironmentObject var userData: UserData
    
    
    @FetchRequest(fetchRequest: Note.allNotessFetchRequest()) var notes: FetchedResults<Note>
    
    //mkmaptype
    var mapType: MKMapType
    
    //latitude of note where it was saved
     var latitude: Double
    
    //longitude of note where it was saved
     var longitude: Double
    
    // North-to-south and east-to-west distance from center
     var deltaLat: Double
     var deltaLong: Double
     var deltaUnit: String
    // Delta unit = "degrees" or "meters"
   
    
    // Annotation title and subtitle to be displayed on map center
    var annotationTitle: String
    

    func makeCoordinator() -> mapViewForNote.mapViewCoordinatorForNote{
        mapViewCoordinatorForNote(self)
    }
    func makeUIView(context: Context) -> MKMapView {
        return mkMap
        

    }
    
    func updateUIView(_ view: MKMapView, context: Context) {

        //remove current annotation and reset the view
        view.delegate = context.coordinator
        let allAnnotations = view.annotations
        view.removeAnnotations(allAnnotations)
        view.mapType = mapType
        view.isZoomEnabled = true
        view.isScrollEnabled = true
        view.isRotateEnabled = false
        
        // Obtain Map's Center Location Coordinate
        let centerLocationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Instantiate an object from the MKCoordinateRegion() class and
        // store its object reference into local variable mapRegion
        var mapRegion = MKCoordinateRegion()
        //let centerZoomRegion = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        if deltaUnit == "degrees" {
            /*
             deltaUnit = "degrees" --> used for large maps such as a country map
             *** 1 degree = 111 kilometers = 69 miles ***
             MKCoordinateSpan identifies width and height of a map region.
             latitudeDelta: North-to-south distance in degrees to display in the map region.
             longitudeDelta:  East-to-west distance in degrees to display in the map region.
             */
            let mapSpan = MKCoordinateSpan(latitudeDelta: deltaLat, longitudeDelta: deltaLong)
            
            // Create a rectangular geographic map region around centerLocationCoordinate
            mapRegion = MKCoordinateRegion(center: centerLocationCoordinate, span: mapSpan)
            
        } else {
            /*
             deltaUnit = "meters" --> used for small maps such as a campus or city map
             *** 1609.344 meters = 1.609344 km = 1 mile ***
             latitudinalMeters: North-to-south distance in meters to display in the map region.
             longitudinalMeters:  East-to-west distance in meters to display in the map region.
             */
            
            // Create a rectangular geographic map region around centerLocationCoordinate
            mapRegion = MKCoordinateRegion(center: centerLocationCoordinate, latitudinalMeters: deltaLat, longitudinalMeters: deltaLong)
        }
        
        // Set the map region with animation
        view.setRegion(mapRegion, animated: true)
        
        //*****************************************
        // Prepare and Set Annotation on Map Center
        //*****************************************
        
        // Instantiate an object from the MKPointAnnotation() class and
        // store its object reference into local variable annotation

        //for each notes, add annotations such that they can be displayed on map
        for aNote in notes {

            let annotation = imageAnnotation()
            let lat = aNote.lat as! CLLocationDegrees
            let long = aNote.long as! CLLocationDegrees
            // Dress up the newly created MKPointAnnotation() object
            annotation.coordinate = CLLocationCoordinate2D()
            annotation.image = UIImage(data: (aNote.photoAndAudio?.photo)!)
            annotation.coordinate.latitude = lat
            annotation.coordinate.longitude = long
            annotation.title = aNote.noteTitle
            annotation.id = aNote.id
            
            annotation.subtitle = aNote.dateVisited
           
            view.addAnnotation(annotation)
        }
        let annotation = MKPointAnnotation()
        
       
        // Dress up the newly created MKPointAnnotation() object
        annotation.coordinate = centerLocationCoordinate
        annotation.title = annotationTitle
       

        // Add the created and dressed up MKPointAnnotation() object to the map view
        view.addAnnotation(annotation)
        
      
    }
    class mapViewCoordinatorForNote: NSObject, MKMapViewDelegate {
        var mapViewController: mapViewForNote
        
        init(_ control: mapViewForNote) {
            self.mapViewController = control
        }
        //Tells the delegate that one of its annotation views was selected.
        func mapView(_ mapView: MKMapView, didSelect view:  MKAnnotationView){
            
            //let region = mapView.region
           
        }
        //Returns the view associated with the specified annotation object.

        func mapView(_ mapView: MKMapView, viewFor
                        annotation: MKAnnotation) -> MKAnnotationView?{
           
            guard !annotation.isKind(of: MKUserLocation.self) else {
                    // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
                    return nil
                }
            if !annotation.isKind(of: imageAnnotation.self) {  //Handle var

                return nil
                }
            //if it's a annotation view, dequeue the reusable annotation view
            var view: imageAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? imageAnnotationView
            if view == nil {
                view = imageAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
            }
            //set the image of annotation
            let annotation = annotation as! imageAnnotation
            view?.image = annotation.image
            view?.annotation = annotation
            //show callout
            view?.canShowCallout = true
       
            //add a right callout button
            let button = UIButton(type: .detailDisclosure)
            view?.rightCalloutAccessoryView = button
            
            return view
            
            
        }
        //Tells the delegate that the user tapped one of the annotation view’s accessory buttons.

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

            //send the note according to the annotation title
            let annotation = view.annotation as! imageAnnotation
            noteDetailSender.send(searchDatabaseForNote(id: (annotation.id)!))
            //send the signal to tell the receiver view to show the callout detail view
            showCalloutDetailSender.send(true)
       

            
        }

    }
    
    
    
}


