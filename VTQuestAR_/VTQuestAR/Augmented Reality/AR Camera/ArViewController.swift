//
//  ArViewController.swift
//  ARKitDrone
//  Zhennan Yao
//

import UIKit
import SceneKit
import ARKit
import Foundation



class ArViewController: UIViewController {
    /// initial Z coordinate when move action starts
    var startingZCord: CGFloat?
    
    /// the last location that user move the virtual obect to
    var lastMovedLocation: SCNVector3?
    
    
    /// the bitmask of current selected object
    var selected = -1
    
    /// the bitmask of the object that wanted to be deleted
    var deleteBitmask = -1
    
    
    /// initial bitmask that will be assigned to the object as they being added to the augmented reality scene
    var bitMask = 0
    
    
    /// current moving node
    var currentNode: SCNNode?
    //    //image part
    //    var image: UIImage?
    //
    //    var captureButton = false
    //    var captureSession = AVCaptureSession()
    //    var backCamera: AVCaptureDevice?
    //    var frontCamera: AVCaptureDevice?
    //    var currentCamera: AVCaptureDevice?
    //    var photoOutput: AVCapturePhotoOutput?
    //    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //DELEGATE
    var delegate: AVCapturePhotoCaptureDelegate?
    
    
    
    /// the arscnview that combine real world scene and ar objects
    var sceneView: ARSCNView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //the initial set up for the ARSCNView
        sceneView = ARSCNView(frame: UIScreen.main.bounds)
        self.view.addSubview(sceneView)
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.scene = SCNScene(named: "art.scnassets/base.scn")!
        
        //register 5 gesture recognizer: delete, move, rotate, zoom, and select.
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.sceneView.addGestureRecognizer(longPressRecognizer)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchPressed))
        self.sceneView.addGestureRecognizer(pinchRecognizer)
        
        let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotatePressed))
        self.sceneView.addGestureRecognizer(rotateRecognizer)
        
        let deleteRecognizer = UITapGestureRecognizer(target: self, action: #selector(deletePressed))
        deleteRecognizer.numberOfTapsRequired = 2
        self.sceneView.addGestureRecognizer(deleteRecognizer)
        
        let selectGesture = UITapGestureRecognizer(target: self, action: #selector(selectPressed))
        selectGesture.numberOfTapsRequired = 1
        self.sceneView.addGestureRecognizer(selectGesture)
        
    }
    
    /// Whenever the user taps a AR object, the selected object will be highlighted in green for 0.5 second with animation.
    /// - Parameter recognizer: the recognizer that recognize single tap action.
    @objc func selectPressed(recognizer: UITapGestureRecognizer) {
        
        guard let recognizerView = recognizer.view as? ARSCNView else { return }
        let touch = recognizer.location(in: recognizerView)
        
        let hitTestResult = self.sceneView.hitTest(touch, options:nil)
        guard let hitNode = hitTestResult.first?.node else { return }
        
        selected = hitNode.categoryBitMask
        
        currentNode = hitNode
        animateSelection(node: currentNode!)
        
    }
    
    /// the animation of highlighting a object node
    /// - Parameter node: the node to be highlighted
    func animateSelection(node: SCNNode) {
        
        var currentNode = node
        while (true) {
            if (currentNode.name == "hokie" || currentNode.name == "helmet" || currentNode.name == "truck" || currentNode.name == "logo") {
                break
            }
            currentNode = (currentNode.parent)!
        }
        
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        
        // unhighlight the object when animation finished
        var initialDiffuseOne: UIColor?
        var initialDiffuseTwo: UIColor?
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            if (currentNode.name == "hokie") {
                let node = currentNode.childNode(withName: "HOKIE", recursively: true)
                let material = node!.geometry!.materials
                for item in material {
                    item.emission.contents = UIColor.black
                }
            }
            
            if (currentNode.name == "helmet") {
                let node = currentNode.childNode(withName: "ID197", recursively: true)
                let material = node!.geometry!.firstMaterial
                material!.emission.contents = UIColor.black
                
                //let node = ID197
            }
            if (currentNode.name == "truck") {
                
                
                let node = currentNode.childNode(withName: "ID2887", recursively: true)
                let material = node!.geometry!.firstMaterial
                material!.emission.contents = UIColor.black
                
            }
            if (currentNode.name == "logo") {
                
                
                let node = currentNode.childNode(withName: "ID345", recursively: true)
                
                let material = node!.geometry!.materials
                for item in material {
                    if item.name == "Color_A21" {
                        item.diffuse.contents = initialDiffuseOne!
                    }
                    if item.name == "material" {
                        item.diffuse.contents = initialDiffuseTwo!
                    }
                }
                
                
            }
            
            SCNTransaction.commit()
        }
        
        if (currentNode.name == "logo") {
            
            let node = currentNode.childNode(withName: "ID345", recursively: true)
            
            let material = node!.geometry!.materials
            for item in material {
                if item.name == "material" {
                    initialDiffuseTwo = (item.diffuse.contents as! UIColor)
                    item.diffuse.contents = UIColor.green
                }
                if item.name == "Color_A21" {
                    initialDiffuseOne = (item.diffuse.contents as! UIColor)
                    item.diffuse.contents = UIColor.green
                }
                
            }
        }
        if (currentNode.name == "hokie") {
            let node = currentNode.childNode(withName: "HOKIE", recursively: true)
            let material = node!.geometry!.materials
            for item in material {
                item.emission.contents = UIColor.green
            }
        }
        if (currentNode.name == "helmet") {
            let node = currentNode.childNode(withName: "ID197", recursively: true)
            let material = node!.geometry!.firstMaterial
            material!.emission.contents = UIColor.green
            
        }
        if (currentNode.name == "truck") {
            
            
            let node = currentNode.childNode(withName: "ID2887", recursively: true)
            let material = node!.geometry!.firstMaterial
            material!.emission.contents = UIColor.green
            
        }
        SCNTransaction.commit()
    }
    
    /// remove a node that is currently selected/marked as "will" be deleted.
    func removeNode() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if node.categoryBitMask == deleteBitmask {
                node.removeFromParentNode()
            }
        }
    }
    
    
    /// When user taps the capture button, the call will be made to take a snapshot of current screen.
    /// - Returns: return the captured screen that will be saved into coredata model
    func didTapRecord()-> UIImage {
        
        let snapShot = self.sceneView.snapshot()
        
        return snapShot
        
    }
    
    
    func addARObject(type: Int) {
        switch type {
        //add a hokie
        case 0:
            let bitMaskAssigned = bitMask+1
            let scene = SCNScene(named: "art.scnassets/hokie.scn")!
            
            let hokieNode = scene.rootNode.childNode(withName: "hokie", recursively: false)!
            
            //self.sceneView.scene.rootNode.addChildNode(helicopterNode)
            let min = hokieNode.boundingBox.min
            let max = hokieNode.boundingBox.max
            
            hokieNode.pivot = SCNMatrix4MakeTranslation(
                min.x + (max.x - min.x)/2,
                min.y + (max.y - min.y)/2,
                min.z + (max.z - min.z)/2
            )
            
            hokieNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
            
            hokieNode.position = SCNVector3(hokieNode.position.x, hokieNode.position.y, hokieNode.position.z - 1)
            
            
            hokieNode.categoryBitMask = bitMaskAssigned
            hokieNode.enumerateChildNodes { (node, _) in
                node.categoryBitMask = bitMaskAssigned
            }
            bitMask = bitMask + 1
            
            if sceneView.scene.rootNode.childNode(withName:"hokie", recursively: false) != nil{
                //when at least one hokie is currently added to the scene. Make a copy, then add another into the scene.
                let copy = hokieNode.clone()
                
                copy.enumerateChildNodes { (node, _) in
                    node.categoryBitMask = bitMaskAssigned
                }
                copy.position = addNodeInfrontOf(inFrontOf: sceneView.pointOfView!, atDistance: 2)
                copy.eulerAngles.y = (sceneView.session.currentFrame?.camera.eulerAngles.y)!
                copy.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
                sceneView.scene.rootNode.addChildNode(copy)
                
            }
            else {
                
                //when the hokie is first time added
                hokieNode.position = addNodeInfrontOf(inFrontOf: sceneView.pointOfView!, atDistance: 2)
                
                hokieNode.eulerAngles.y = (sceneView.session.currentFrame?.camera.eulerAngles.y)!
                hokieNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
                self.sceneView.scene.rootNode.addChildNode(hokieNode)
                
            }
        //add a helmet
        case 1:
            
            let bitMaskAssigned = bitMask+1
            let scene = SCNScene(named: "art.scnassets/helmet.scn")!
            let helmet = scene.rootNode.childNode(withName: "helmet", recursively: false)!
       
            helmet.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
          
            helmet.position = SCNVector3(0, 0, -1)
            let min = helmet.boundingBox.min
            let max = helmet.boundingBox.max
            
            helmet.pivot = SCNMatrix4MakeTranslation(
                min.x + (max.x - min.x)/2,
                min.y + (max.y - min.y)/2,
                min.z + (max.z - min.z)/2
            )
            helmet.categoryBitMask = bitMaskAssigned
            helmet.enumerateChildNodes { (node, _) in
                node.categoryBitMask = bitMaskAssigned
            }
            bitMask = bitMask + 1
            
            
            if sceneView.scene.rootNode.childNode(withName:"helmet", recursively: false) != nil{
                
                let copy = helmet.clone()
                copy.position = SCNVector3(helmet.position.x, helmet.position.y, helmet.position.z - 2)
                copy.enumerateChildNodes { (node, _) in
                    node.categoryBitMask = bitMaskAssigned
                }
                copy.position = addNodeInfrontOf(inFrontOf: sceneView.pointOfView!, atDistance: 2)
            
                copy.eulerAngles.y = (sceneView.session.currentFrame?.camera.eulerAngles.y)!
                copy.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
                sceneView.scene.rootNode.addChildNode(copy)
            
            }
            else {
               
                helmet.position = addNodeInfrontOf(inFrontOf: sceneView.pointOfView!, atDistance: 2)
                
                helmet.eulerAngles.y = (sceneView.session.currentFrame?.camera.eulerAngles.y)!
                helmet.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
                self.sceneView.scene.rootNode.addChildNode(helmet)
            }
            
            
            
        //add a vt rescue truck
        case 2:
            let bitMaskAssigned = bitMask+1
            let scene = SCNScene(named: "art.scnassets/truck.scn")!
            
            let truck = scene.rootNode.childNode(withName: "truck", recursively: false)!
       
            let min = truck.boundingBox.min
            let max = truck.boundingBox.max
            
            truck.pivot = SCNMatrix4MakeTranslation(
                min.x + (max.x - min.x)/2,
                min.y + (max.y - min.y)/2,
                min.z + (max.z - min.z)/2
            )
            
            truck.scale = SCNVector3(x: 0.002, y: 0.002, z: 0.002)
            
            truck.position = SCNVector3(truck.position.x, truck.position.y, truck.position.z - 1)
            
            
      
            truck.categoryBitMask = bitMaskAssigned
            truck.enumerateChildNodes { (node, _) in
                node.categoryBitMask = bitMaskAssigned
            }
            bitMask = bitMask + 1
            
            if sceneView.scene.rootNode.childNode(withName:"truck", recursively: false) != nil{
              
                let copy = truck.clone()
                copy.position = SCNVector3(truck.position.x, truck.position.y, truck.position.z - 2)
                copy.enumerateChildNodes { (node, _) in
                    node.categoryBitMask = bitMaskAssigned
                }
                copy.position = addNodeInfrontOf(inFrontOf: sceneView.pointOfView!, atDistance: 2)
               
                copy.eulerAngles.y = (sceneView.session.currentFrame?.camera.eulerAngles.y)!
                copy.scale = SCNVector3(x: 0.002, y: 0.002, z: 0.002)
                sceneView.scene.rootNode.addChildNode(copy)
            
                
            }
            else {
                
                truck.position = addNodeInfrontOf(inFrontOf: sceneView.pointOfView!, atDistance: 2)
               
                truck.eulerAngles.y = (sceneView.session.currentFrame?.camera.eulerAngles.y)!
                truck.scale = SCNVector3(x: 0.002, y: 0.002, z: 0.002)
                self.sceneView.scene.rootNode.addChildNode(truck)
            }
        //add a vt logo
        case 3:
            let bitMaskAssigned = bitMask+1
            let scene = SCNScene(named: "art.scnassets/logo.scn")!
            
            let logo = scene.rootNode.childNode(withName: "logo", recursively: false)!
    
            let min = logo.boundingBox.min
            let max = logo.boundingBox.max
            
            logo.pivot = SCNMatrix4MakeTranslation(
                min.x + (max.x - min.x)/2,
                min.y + (max.y - min.y)/2,
                min.z + (max.z - min.z)/2
            )
          
            
            logo.scale = SCNVector3(x: 0.002, y: 0.002, z: 0.002)
           
            logo.position = SCNVector3(0, 0, -2)
            
            logo.categoryBitMask = bitMaskAssigned
            
            logo.enumerateChildNodes { (node, _) in
                node.categoryBitMask = bitMaskAssigned
            }
            bitMask = bitMask + 1
            
            if sceneView.scene.rootNode.childNode(withName:"logo", recursively: false) != nil{
                
                let copy = logo.clone()
              
                copy.enumerateChildNodes { (node, _) in
                    node.categoryBitMask = bitMaskAssigned
                }
                copy.position = addNodeInfrontOf(inFrontOf: sceneView.pointOfView!, atDistance: 2)
               
                copy.eulerAngles.y = (sceneView.session.currentFrame?.camera.eulerAngles.y)!
                copy.scale = SCNVector3(x: 0.002, y: 0.002, z: 0.002)
                sceneView.scene.rootNode.addChildNode(copy)
              
                
            }
            else {
               
                logo.position = addNodeInfrontOf(inFrontOf: sceneView.pointOfView!, atDistance: 2)
               
                logo.eulerAngles.y = (sceneView.session.currentFrame?.camera.eulerAngles.y)!
                logo.scale = SCNVector3(x: 0.002, y: 0.002, z: 0.002)
                self.sceneView.scene.rootNode.addChildNode(logo)
              
            }
            
        default:
            print("default")
        }
    }
    
    
    /// calculate the 3d coordinates used to place a node in in front of another node at certain distance
    /// - Parameters:
    ///   - node: The node used as reference
    ///   - distance: the distance away from the reference node
    /// - Returns: return the 3d position of the new node which will be added to the scene
    func addNodeInfrontOf(inFrontOf node: SCNNode, atDistance distance: Float) -> SCNVector3 {
        let localPosition = SCNVector3(x: 0, y: 0, z: Float(CGFloat(-distance)))
        //nil is automatically scene space
        let scenePosition = node.convertPosition(localPosition, to: nil)
        
        return scenePosition
    }
    
    
    /// rotate current selected node
    /// - Parameter gesture: rotation gesture recognizer
    @objc func rotatePressed(gesture: UIRotationGestureRecognizer) {
        guard gesture.view != nil else { return }
        
        //1. Get The Current Rotation From The Gesture
        let rotation = Float(gesture.rotation)
        
        //2. If The Gesture State Has Changed Set The Nodes EulerAngles.y
        if gesture.state == .changed{
        
            
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                if node.categoryBitMask == selected {
                    if node.name == "helmet" || node.name == "logo" || node.name == "hokie" || node.name == "truck"{
                        node.eulerAngles.y = node.eulerAngles.y + rotation
                       
                    }
                }
            }
            
        }
        
     
    }
    
    /// delete current marked node
    /// - Parameter recognizer: double tap gesture recognizer
    @objc func deletePressed(recognizer: UITapGestureRecognizer) {
      
        guard let recognizerView = recognizer.view as? ARSCNView else { return }
        let touch = recognizer.location(in: recognizerView)
        let hitTestResult = self.sceneView.hitTest(touch, options: nil)
        guard (hitTestResult.first?.node) != nil else { return }
        
        deleteBitmask = (hitTestResult.first?.node.categoryBitMask)!
        showDeleteAlert.send(true)

    }
    
    /// Zoom in/out for currently selected node
    /// - Parameter gestureRecognizer: pinch gesture recognizer
    @objc func pinchPressed(gestureRecognizer: UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let scale = Float(gestureRecognizer.scale)
            
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                if node.categoryBitMask == selected {
                    
                    
                    if node.name == "helmet" || node.name == "logo" || node.name == "hokie" || node.name == "truck"{
                    
                        let newscalex = scale * node.scale.x
                        let newscaley = scale * node.scale.y
                        let newscalez = scale * node.scale.z
                        node.scale = SCNVector3(newscalex, newscaley, newscalez)
                        
                        gestureRecognizer.scale = 1.0
                    }

                }
                
            }
    
        }
      
    }
    
    /// long pressed a node, then user can move the node in 3d space
    /// - Parameter recognizer: long press gesture recognizer
    @objc func longPressed(recognizer: UILongPressGestureRecognizer) {
        
        guard let recognizerView = recognizer.view as? ARSCNView else { return }
        let touch = recognizer.location(in: recognizerView)
        
        if recognizer.state == .began {
            // perform a hitTest
            let hitTestResult = self.sceneView.hitTest(touch, options: nil)

            guard (hitTestResult.first?.node) != nil else { return }
            currentNode = hitTestResult.first?.node
            while (true) {
                if (currentNode!.name == "hokie" || currentNode!.name == "helmet" || currentNode!.name == "truck" || currentNode!.name == "logo") {
                    break
                }
                currentNode = currentNode?.parent
            }
            animateSelection(node: currentNode!)
     
            selected = currentNode!.categoryBitMask
            
            lastMovedLocation = hitTestResult.first?.worldCoordinates
            
            startingZCord = CGFloat(sceneView.projectPoint(lastMovedLocation!).z)
            
        } else if recognizer.state == .changed {
            
            if (startingZCord != nil) {
                let worldTouchPosition = sceneView.unprojectPoint(SCNVector3(touch.x, touch.y, startingZCord!))
                let action = SCNAction.moveBy(x: CGFloat(worldTouchPosition.x - lastMovedLocation!.x), y: CGFloat(worldTouchPosition.y - lastMovedLocation!.y), z: CGFloat(worldTouchPosition.z - lastMovedLocation!.z), duration: 0.0)
                
              
                //hokieNode!.runAction(action)
                currentNode!.runAction(action)
                self.lastMovedLocation = worldTouchPosition
            }
            else {
                return
            }
            
        } else if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed{
            
            startingZCord = nil
            lastMovedLocation = nil
            currentNode = nil
       
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewwillA")
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillD")
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}

// MARK: - ARSCNViewDelegate

extension ArViewController: ARSCNViewDelegate {
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("Session was interrupted.")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("Session interruption has ended.")
    }
}

