//
//  ML.swift
//  UIDemo
//
//  Created by zhennan on 2020/5/26.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SpriteKit
import ARKit
import SceneKit
import Vision
import SwiftUI
import CoreML
import CoreData
import Combine
import GoogleMaps
import GooglePlaces
import CoreLocation
//The reason I decided to use passthroughsubject is because if I use @State. The ML view will rerender the whole body each time some @State var changes. This cause the ML parent view to splash sometimes. What I want is to only update the container view which displays the building detail(child view) rather than update the whole view hierarchy(parent+child). Therefore, passthroughsubject can help to only rerender the child view (buildingOverlay class) and save the cost(memory, time, visual user experience) for rerendering both parent view(ML.swift body + buildingOverlay.swift body)

//This publisher is used to notify the container view which display the information whenever the building is recognized by CoreML model. Received in buildingOverlay class. If the publisher sends out "true", then the container view will change its opacity to 1. And it will be trasparent if it sends out "false". This publisher basically does the trick to hide and show the container overlay view according to the circumstances.
public let showPublisher = PassthroughSubject<Bool, Never>()
//This publisher basically helps to notify the building information overlay view to update the building information. When a new building is recognized by CoreML, the building info should be updated immediately.
public let buildingPublisher = PassthroughSubject<Building, Never>()

let applicationDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//
var visionRequests = [VNRequest]()
let dispatchQueueML = DispatchQueue(label: "mlqueue")

var buildingRecognized = Building()
//@Published var currentBuilding = "Ambler Johnston Hall" {

var annotations = [nodeAnnotation]()

struct Recognition: View {
    
    //The ARScene to interact with
    let scene = Scene()
    //make it true when user leaves current view
    @State var disappear = false
    //locationmanager
    @ObservedObject var locationManager = VTRecognitionLocationManager()
    //Default building overlay
    @State var currentBuilding = "Ambler Johnston Hall"
    //core data
    @Environment(\.managedObjectContext) var managedObjectContext
    //default selection for the first time is ML
    @State var selected = "ML"
    //default textDisplayed
    @State var textDisplayed = "Not a Campus Building"
    //Current mode selection index
    @State var selectedTypeIndex = 0
    var type = ["ML", "AR"]
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                VStack(spacing: 0){
                    ZStack {
                        HStack(spacing: 15){
                            
                            
                            Button(action: {
                                
                                self.selected = "ML"
                                self.scene.removeAllChildren()
                                self.runFirstMLModel()
                                
                            }) {
                                
                                VStack{
                                    
                                    Image(systemName: "m.circle").font(.system(size: 19, weight: .regular))
                                        .foregroundColor(self.selected == "ML" ? Color.blue : Color.black.opacity(0.2))
                                    
                                    Circle().fill(self.selected == "ML" ? Color.blue : Color.clear).frame(width: 5, height: 5).padding(.vertical,4)
                                }
                                
                            }
                            
                            Button(action: {
                                //hide the building overlay for ML
                                showPublisher.send(false)
                                //mark current selection to "AR"
                                self.selected = "AR"
                                //run AR session to display green pins
                                runAR(currentLocationCL())
                               
                                
                            }) {
                                VStack{
                                    Image(systemName: "a.circle").font(.system(size: 19, weight: .regular))
                                        .foregroundColor(self.selected == "AR" ? Color.blue : Color.black.opacity(0.2))
            
                                    Circle().fill(self.selected == "AR" ? Color.blue : Color.clear).frame(width: 5, height: 5).padding(.vertical, 4)
                                }
                                
                                
                                
                            }
                            
                        }
                    }.frame(height: 50)
                        .padding(.horizontal)
                        .padding(.top, 5)
                    
                    Divider()
                    
                    ZStack(alignment: .center) {
                        ARViewContainer(scene: scene, mode: self.$selected).overlay(self.selected == "ML" ? nil : PlaceFoundView(), alignment: .bottom)
                        //ZStack(alignment: .center) {
                        if (self.selected == "ML") {
                        mlBuildingOverlay()
                        }
                        if (self.selected == "AR") {
                            arBuildingOverlay()
                        }
                        //TextField(self.textDisplayed).multilineTextAlignment(.trailing)
                        Text(self.textDisplayed).bold().font(.system(size: 40)).opacity(self.selected == "ML" ? 1 : 0).lineLimit(nil).frame(width: UIScreen.main.bounds.width * 0.7).multilineTextAlignment(.center)
                       
                    }
                    
                    
                    
                    
                    
                    //When phone is shaking, switch between ML and AR mode
                }.onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
                    if (self.selected == "ML") {
                        showPublisher.send(false)
                        self.selected = "AR"
                        //call runAR() to get green pins nearby
                        runAR(self.locationManager.lastLocation!)
                    }
                    else {
                        self.selected = "ML"
                        self.runFirstMLModel()
                    }
                }
                
                
                
                
            }.navigationBarTitle("", displayMode: .inline).navigationBarHidden(true).customNavigationViewStyle()
        }.onAppear() {
            //mark the view as appearing
            disappear = false
            //start updating the location
            self.locationManager.locationManager.startUpdatingLocation()
            //run ML recognition
            if self.selected == "ML" {
                self.runFirstMLModel()
            }
            else {
                //run AR
                runAR(currentLocationCL())
            }
            
        }.onDisappear() {
            //mark current view as disappeared
            disappear = true
            self.locationManager.locationManager.stopUpdatingLocation()

        }
    }
    
    //This func is used to search a single building and fetch itself back for displaying the building info.
     func searchDatabase(str: String) -> Building {
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
            buildingRecognized = try self.managedObjectContext.fetch(fetchRequest)[0]
            
        } catch {
            print("Fetch Request Failed!")
        }
        //return the single building recognized by ML model.
        return buildingRecognized
    }
    
    
    //run the first ML model. The first ML model is to check whether the image input is a building or not. If it's a building, then go to second ML model to check if the building is a VT campus building, if not, there is no need to run the second model.
    func runFirstMLModel() {
        print("first model runned")
        //declare the ml model, show the error if occurs
        guard let selectedModel = try? VNCoreMLModel(for:
            model1norotateEZ().model) else {
                //model2norotateCompo().model) else {
                fatalError("Could not load model")
        }
        
        // Vision and CoreML image classification model Request get set up
        let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandlerModelone)
        //set up the input image(from user's real time phone camera) crop and scale option
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        //save the image crop and scale option and classification request into the vision request array. This request will be used by ML model to analyze.
        visionRequests = [classificationRequest]
        
        // Begin the Loop to Update CoreML model
        realTimeLoopCoreML()
    }
    func realTimeLoopCoreML() {
        //run CoreML continuously whenever the model is needed.
        
        //When current view is present && current selected mode is "ML" not "AR", then run the coreML model.
        if (disappear == false && self.selected == "ML") {
            
            dispatchQueueML.async  {
                //Run the core ml model
                self.runCoreMl()
                
                //loop this function until view disappears or mode is changed to "AR"
                self.realTimeLoopCoreML()
                
            }
        }
    }
    
    func runCoreMl() {
        // Get the real time captured camera image pixel buffer
        if let pixbuff : CVPixelBuffer? = (arView.session.currentFrame?.capturedImage) {
            //convert the cvPixelBuffer to image
            let ciImage = CIImage(cvPixelBuffer: pixbuff!)
            //用这个来处理图片方向问题
            //let ima = sceneView.snapshot()
            //let imageOrientation = CGImagePropertyOrientation(rawValue: UInt32(ima.imageOrientation.rawValue))!
            
            //set confidence threshold, find best for my model later on
            //https://developer.apple.com/documentation/coreml/understanding_a_dice_roll_with_vision_and_object_detection
            
            
            
            // Prepare CoreML&&Vision request handler with camera image
            let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            // Run vision image request by CoreML
            do {
                //vision request is what we have set up earlier with the image crop and scale option
                try imageRequestHandler.perform(visionRequests)
            } catch {
                print(error)
            }
        } else {return}
        
        
    }
    //process the vision request using CoreML model.
    func classificationCompleteHandlerModelone(request: VNRequest, error: Error?) {
        
        // catcb the errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        //retreive the request result returned by CoreML and vision
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        // Get Classifications results (recognized building names in array)
        let classifications = observations[0...1] // top 3 possible building results
            //1st element is the most likely building, third is the most unlikely building. Ranked by confidence score. Confident scores add up to 1 all the time. The single result who has higher condifent score means the ML model think this building match the camera image.
            .compactMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        //analyze the classification results
        DispatchQueue.main.async {
            
            let currentLoc = CLLocationCoordinate2D(latitude: 37.229695, longitude: -80.424279)
            if (applicationDelegate.polygon.contains(coordinate: currentLoc) == false) {
                print("not on campus")
                self.textDisplayed = "Not on Campus Area"
                return
            }
            
            // Get the single result with higest confidenc/prediction score. (Most likely to be the building that need to be recognized)
            let topPrediction = classifications.components(separatedBy: "\n")[0]
            let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            // get the confidnet score
            let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
            
            //when the score is not nil and is higher than 20%, continue then
            if (topPredictionScore != nil && topPredictionScore! > 0.2) {
                //Note that this is the first model we used to filter vt campus building and non-campus building. The model is not perfect and is not possible to be perfect by the current best practice. Therefore, sometimes the model predicts a random building to be a campus building. Therefore, we require the users to use the app to only recognize the VT campus building.
                if (topPredictionName == "vtbuildings") {
                    
                    print("it's a building")
                    
                    //run second model since the first model already validate this is a campus building.
                    // Setup the second Vision & coreML Model
                    guard let selectedModel = try? VNCoreMLModel(for: model2TenNorotateCompo().model) else {
                        //hehe().model) else {
                        fatalError("Model was not loaded successfully")
                    }
                    
                    // Set up Vision-CoreML Request similarly to what we have done for the first model.
                    let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: self.classificationCompleteHandlerModeltwo)
                    classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
                    visionRequests = [classificationRequest]
                    
                    
                }
                //the case when the camera image was predicted as non campus building. Then just display "not a building" to the user.
                if (topPredictionName == "none") {
                    
                    print("none")
                    //tell the buildingOverlay view through passthrough subject to have opacity of zero(completely hidden to the user, since it's not a building, nothing has to be shown)
                    showPublisher.send(false)
                    
                }
            }
            
        }
        
        
    }
    
    //similarly to classificationCompleteHandlerModelone, run the second model if the image is a campus building.
    func classificationCompleteHandlerModeltwo(request: VNRequest, error: Error?) {
        
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        
        let classifications = observations[0...9] // top 3 results
            .compactMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        
        DispatchQueue.main.async {
            
            let allPrediction = classifications.components(separatedBy: "\n")
            
            let topPrediction = classifications.components(separatedBy: "\n")[0]
            let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
            
            let currentLocation = self.locationManager.lastLocation
            
            
            let tem = ["Ambler Johnston Hall", "Architecture Annex", "Armory"]
            let randomInt = Int.random(in: 0..<2)
            let searchedBuilding = self.searchDatabase(str: tem[randomInt])
            
            //method 1 to filter result
            var refinedPrediction = [String]()
            print("original: \(allPrediction)")
            for result in allPrediction {
                let buildingLocation = CLLocation(latitude: searchedBuilding.latitude as! CLLocationDegrees, longitude: searchedBuilding.longitude as! CLLocationDegrees)
                let distanceUserAndBuilding = (currentLocation?.distance(from: buildingLocation))! as Double
                if distanceUserAndBuilding < 100.0 {
                    refinedPrediction.append(result)
                }
                //filter the buildings that are too far away (> certain threshold) and remove them from the
                //result list
                //*use center point of building to decide distance from user
            }
            print("refined: \(refinedPrediction)")
            
            //method 2 ~
            //Compare the current location and all buildings and find a group of building
            //that are closest to user then compare their confident score
            //*use polygons to decide distance from user
            //use google map sdk
            
            
            if (topPredictionScore != nil ) {
                
                print(topPredictionName)
                
                //objectWillChange.send()
                
                self.currentBuilding = topPredictionName
                //changee = true
                //self.showOverlay = true
                if (self.selected == "ML") {
                    showPublisher.send(true)
                }
                
                buildingPublisher.send(self.searchDatabase(str: tem[randomInt]))
               
                
                
                self.runFirstMLModel()
                
            }
            
            
        }
    }
    
    
}
//will notify the number of green pins near the user
let showPlacesCount = PassthroughSubject<Int, Never>()
public func runAR(_ location: CLLocation) {

    //load annotations for buildings near the user
    let position = getAnnotations(location)
    //send the num of annotations
    showPlacesCount.send(position)
    //remove all nodes to properly set up the view
     NotificationCenter.default.post(name: Notification.Name("shouldRemoveNodes"), object: nil)

}
//Return the number of annotations, also prepare ARAnchor for each annotation.
public func getAnnotations(_ location: CLLocation) -> Int {
   let loader = loadAnnotationNotes()
    var ret = -1
    
    

    loader.getPois(location: location) {(poiListReturned, errMessage) in
        if let err = errMessage {
            print(err)
            ret = 0
        }
        else if let pois = poiListReturned {
           
            let annotRect = CGRect(x: 0, y: 0, width: 250, height: 70)
            
            var poiNearest: Double = 0
            var poiFarthest: Double = 0
            for poi in pois {
                let geometry = poi["geometry"] as? [String: Any]
                let poiLoc = loader.getLocationFrom(dict: geometry!)!
                let distanceMeters: Double = location.distance(from: poiLoc)
                if distanceMeters > poiFarthest {
                    poiFarthest = distanceMeters
                }
                if poiNearest == 0 {
                    poiNearest = distanceMeters
                }
                else if distanceMeters < poiNearest {
                    poiNearest = distanceMeters
                }
            }
           
            for poi in pois {

                
                let title = poi["name"] as! String
                let geometry = poi["geometry"] as? [String: Any]
                let poiLocation = loader.getLocationFrom(dict: geometry!)!
                let distanceInMeters: Double = location.distance(from: poiLocation)

                let bearing = MatrixHelper.bearingBetween(startLocation: location, endLocation: poiLocation)
                let anchorDist = distanceInMeters

                var originmatrix = matrix_identity_float4x4
                originmatrix.columns.3.z = -1 * Float(anchorDist)
                
                //use quaternion to rotate
                let templateMatrix = float4x4(simd_quatf(angle: bearing  * .pi / 180 * (-1), axis: SIMD3(0, 1, 0)))
                //multiply the temlate with origin can rotate the origin matrix
                let rotateMatrix = templateMatrix * originmatrix
                
                
                //bearing returned is always positive, but the method rotate counterclockwise when is negative, thus, multiply by -1
                //                    let bearingTransform = MatrixHelper.rotateMatrixAroundY(degrees: bearing * -1, matrix: origin)
                //height is here
                let transform = MatrixHelper.translate(x: 0, y: 10, z: 0)                    // anchor
                
                
                let final = rotateMatrix * transform
                let anchor = ARAnchor(transform: final)
                
                // create an append annotation
                let annot = nodeAnnotation(frame: annotRect, identifier: anchor.identifier, title: title)
                annot.distanceText = String(Int(distanceInMeters))
                //print(distanceMeters)
                annot.distanceUnitsText = "meters"
                //
                annotations.append(annot)
                
                // Add a new anchor to the session.
                arView.session.add(anchor: anchor)
                
            }
            ret = pois.count
        }
        else {
            ret = 0
        }
        
    }
    return ret

    
}

