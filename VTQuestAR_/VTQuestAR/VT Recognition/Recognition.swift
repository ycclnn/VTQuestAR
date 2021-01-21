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
                                
                                //remove existing nodes
                                NotificationCenter.default.post(name: Notification.Name("shouldRemoveNodes"), object: nil)
                                //run AR session to display green pins
                                setupRunAR()
                                
                                //runAR(currentLocationCL())
                               
                                
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
                   
                    ZStack {
                        ARViewContainer(scene: scene, mode: self.$selected).overlay(self.selected == "ML" ? nil : PlaceFoundView(), alignment: .bottom)
                        Text(self.textDisplayed).bold().font(.system(size: 40)).opacity(self.selected == "ML" ? 1 : 0).lineLimit(nil).frame(width: UIScreen.main.bounds.width * 0.7).multilineTextAlignment(.center)
                        //ZStack(alignment: .center) {
                        if (self.selected == "ML") {
                            mlBuildingOverlay()
                        }
                        if (self.selected == "AR") {
                          
                            arBuildingOverlay()
                            
                        }
                        //TextField(self.textDisplayed).multilineTextAlignment(.trailing)
                       
                    
                    }
                    
                   
                    
                    
                    
                    //When phone is shaking, switch between ML and AR mode
                }.onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
                    //remove existing nodes
                    NotificationCenter.default.post(name: Notification.Name("shouldRemoveNodes"), object: nil)
                    if (self.selected == "ML") {
                        showPublisher.send(false)
                        self.selected = "AR"
                        
                        //call runAR() to get green pins nearby
                        setupRunAR()
                        //runAR(self.locationManager.lastLocation!)
                    }
                    else {
                        self.selected = "ML"
                        self.runFirstMLModel()
                    }
                }
                
                
                
                
            }.navigationBarTitle("", displayMode: .inline).navigationBarHidden(true).customNavigationViewStyle()
        }.navigationViewStyle(StackNavigationViewStyle())
        .onAppear() {
            //mark the view as appearing
            self.disappear = false
            //start updating the location
            self.locationManager.locationManager.startUpdatingLocation()
            //run ML recognition
            if self.selected == "ML" {
                self.runFirstMLModel()
            }
            else {
                //run AR
                setupRunAR()
                //runAR(currentLocationCL())
            }
            
        }.onDisappear() {
            //mark current view as disappeared
            self.disappear = true
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
        
        let config = MLModelConfiguration()
        //declare the ml model, show the error if occurs
        guard let selectedModel = try? VNCoreMLModel(for:
                                                        model1norotateEZ(configuration: config).model) else {
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
                if (applicationDelegate.polygon.contains(coordinate: currentLocationCL().coordinate) == false) {

                    self.textDisplayed = "Not on Campus"
                    //return
                    //self.runCoreMl()
                }
                if (applicationDelegate.polygon.contains(coordinate: currentLocationCL().coordinate) == true) {
                    self.textDisplayed = "Not a Campus Building"
                    //Run the core ml model
                    self.runCoreMl()
                }
                
                //loop this function until view disappears or mode is changed to "AR"
                self.realTimeLoopCoreML()
                
            }
        }
    }
    
    func runCoreMl() {
        // Get the real time captured camera image pixel buffer
        
        
        if let pixbuff : CVPixelBuffer? = (arView.session.currentFrame?.capturedImage) {
            

            
            //set confidence threshold, find best for my model later on
            //https://developer.apple.com/documentation/coreml/understanding_a_dice_roll_with_vision_and_object_detection
            
            //change orientation to right because when reading input from back camera in portrait mode, the image is rotated.
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixbuff!, orientation: .right, options: [:])

            // Prepare CoreML&&Vision request handler with camera image
            //let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
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
        print("one")
        // catcb the errors
        if error != nil {
            print("catch a error for classification handler!")
            return
        }
        guard let observations = request.results else {
            print("There are no results found")
            return
        }
        
        // Get Classifications results (recognized building names in array)
        let classifications = observations[0...1] // top 2 possible building results
            //1st element is the most likely building, third is the most unlikely building. Ranked by confidence score. Confident scores add up to 1 all the time. The single result who has higher condifent score means the ML model think this building match the camera image.
            .compactMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        //analyze the classification results
        DispatchQueue.main.async {
            

            
            // Get the single result with higest confidenc/prediction score. (Most likely to be the building that need to be recognized)
            let topPrediction = classifications.components(separatedBy: "\n")[0]
            let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            // get the confidnet score
            let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
            
            //when the score is not nil and is higher than 20%, continue then
            if (topPredictionScore != nil && topPredictionScore! > 0.2) {
                //Note that this is the first model we used to filter vt campus building and non-campus building. The model is not perfect and is not possible to be perfect by the current best practice. Therefore, sometimes the model predicts a random building to be a campus building. Therefore, we require the users to use the app to only recognize the VT campus building.
                if (topPredictionName == "vtbuildings") {
                    
                
                    //run second model since the first model already validate this is a campus building.
                    // Setup the second Vision & coreML Model
                    let config = MLModelConfiguration()
                    guard let selectedModel = try? VNCoreMLModel(for: thirty_bc(configuration: config).model) else {
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
                    
                   
                    //tell the buildingOverlay view through passthrough subject to have opacity of zero(completely hidden to the user, since it's not a building, nothing has to be shown)
                    showPublisher.send(false)
                    
                }
            }
            
        }
        
        
    }
    
    //similarly to classificationCompleteHandlerModelone, run the second model if the image is a campus building.
    func classificationCompleteHandlerModeltwo(request: VNRequest, error: Error?) {
        
        if error != nil {
            print("catch a error for classification handler!")
            return
        }
        guard let observations = request.results else {
            print("There are no results found")
            return
        }
        
       
        let classifications = observations[0...9] // top 3 results
            .compactMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        
        DispatchQueue.main.async {
            
            let allPrediction = classifications.components(separatedBy: "\n")
            

            
            //method 1 to filter result
            var refinedPrediction = [String]()
          
            for result in allPrediction {
                let buildingSearched = self.searchDatabase(str: result.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces))
                if buildingSearched.latitude != nil {
                let buildingLocation = CLLocation(latitude: buildingSearched.latitude as! CLLocationDegrees, longitude: buildingSearched.longitude as! CLLocationDegrees)
                //let loc = CLLocation(latitude:37.231193, longitude:-80.421608)
                    let distanceUserAndBuilding = (currentLocationCL().distance(from: buildingLocation)) as Double
               
                    if distanceUserAndBuilding < 100.0 && Float(result.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))! > 0.01{
                    refinedPrediction.append(result)
                }
                }
                //filter the buildings that are too far away (> certain threshold) and remove them from the
                //result list
                //*use center point of building to decide distance from user
            }

            //method 2 ~
            //Compare the current location and all buildings and find a group of building
            //that are closest to user then compare their confident score
            //*use polygons to decide distance from user
            //use google map sdk
            if (refinedPrediction.count == 0) {
                
                showPublisher.send(false)
                return
            }
            let topName = refinedPrediction[0].components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
           
                
              
                //changee = true
                //self.showOverlay = true
                if (self.selected == "ML") {
                    showPublisher.send(true)
                }
               
                buildingPublisher.send(self.searchDatabase(str: topName))
                
                self.runFirstMLModel()
                
           
            
            
        }
    }
    
    
}

public func runAR(_ location: CLLocation) {

    
    //load annotations for buildings near the user
    let count = getAnnotations(location)
    if count == -1 {
        print("didn't get any annotation around user")
    }

}
//Return the number of annotations, also prepare ARAnchor for each annotation.
public func getAnnotations(_ location: CLLocation) -> Int {
    let loader = loadAnnotationNotes()
    var ret = -1
    loader.getGreenPins(location: location) {(greenPinsReturned, error) in
        if let err = error {
            print(err)
            ret = 0
        }
        else if let pinsReturned = greenPinsReturned {
   
            let annotFrame = CGRect(x: 0, y: 0, width: 250, height: 70)
          
          
            for pin in pinsReturned {

                
                let title = pin["name"] as! String
                let lat = pin["latitude"] as! NSNumber
                let long = pin["longitude"] as! NSNumber
                let latitude = lat.doubleValue
                let longitude = long.doubleValue
             
                let pinLocation = CLLocation(latitude: latitude, longitude: longitude)
               
              
    
                //calculate the bearing between user current location and building location.
                //In navigation, bearing is the horizontal angle between the direction of an object and another object. Since the earth is a sphere, we need to calculate bearing to get the angle.
                //With bearing, we are able to location green pins and assign it correct angle relative to user phone camera
                let bearing = BearingHelper.calculateBearing(startLocation: location, endLocation: pinLocation)
                //We also need to calculate the distance information between user and buildings to assign green pins
                //With both bearing(angle) and the distance, we can place green pins in AR with accurate position and angle to make the pins look like exactly on the building.
                let distanceUserAndPin: Double = location.distance(from: pinLocation)
                
                //Create a matrix for translation
                var translationMatrix = matrix_identity_float4x4
                //assign its Z-value equals to the distance between user and pin, because Z-axis in 3D is far to close.
                translationMatrix.columns.3.z = -1 * Float(distanceUserAndPin)
                
                //use quaternion to create a rotation matrix that use bearing we just calculated to assign green pins with proper angles.
                //bearing value is always positive (rotate clockwise) ,but here we want it to rotate counterclockwse, so we multiply it by -1.
                let rotateMatrix = float4x4(simd_quatf(angle: bearing  * .pi / 180 * (-1), axis: SIMD3(0, 1, 0)))
                //Combine both translation matrix and rotation matrix
                let rotateAndTranslationMatrix = rotateMatrix * translationMatrix
                
                //we want to create another matrix to assign each green pin with height: 10 meters
                //we only assign y value because y-axis in 3D is sky and ground.
                var translateHeightMatrix = matrix_identity_float4x4
                translateHeightMatrix.columns.3.x = 0
                translateHeightMatrix.columns.3.y = 10
                translateHeightMatrix.columns.3.z = 0
                
                
                //combine the information including angle, distance, height of green pins together and make it ready for the final transformation.
                let finalTransform = rotateAndTranslationMatrix * translateHeightMatrix
                
                //Assign a new anchor with the transform information we derive above.
                //Meaning create an anchor in 3D space holding green pins
                let anchor = ARAnchor(transform: finalTransform)
                
            
                // Add a new anchor wth correct location/position information to the ARsession.
                arView.session.add(anchor: anchor)
                
                //so far, the anchor is placed in 3D space, but without any information, it is blank and user cannot see anything
                //Thus, we need to create a annotation holding the green pins information such as green pin image data, and we assign images to the anchors to visualize the pins.
                let annot = nodeAnnotation(frame: annotFrame, identifier: anchor.identifier, title: title)
              
                //Append the annotation
                annotations.append(annot)

                
            }
           //total number of pins should returned and displayed
            ret = pinsReturned.count
        }
        else {
            ret = 0
        }
        
    }
    //total number of pins should returned and displayed
    return ret

    
}

//use to rotate the input image for image classifier
extension UIImage.Orientation {
    var exifOrientation: Int32 {
        switch self {
            case .up: return 1
            case .down: return 3
            case .left: return 8
            case .right: return 6
            case .upMirrored: return 2
            case .downMirrored: return 4
            case .leftMirrored: return 5
            case .rightMirrored: return 7
        @unknown default:
            return -1
        }
    }
}

