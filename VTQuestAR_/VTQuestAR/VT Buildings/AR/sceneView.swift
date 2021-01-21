//
//  sceneView.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/27.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import Foundation
import ARKit
import UIKit

/// The ARSCNView that shows the buildings in AR
class sceneView: ARSCNView {
    
    /// Remove all node in the scene
    func removeAllNodes() {
        for node in self.scene.rootNode.childNodes {
            node.removeFromParentNode()
        }

        NotificationCenter.default.removeObserver(self)
        
    }
    
    //Add vertical photo ring
    func addPhotoRing_V(vector3: SCNVector3, left: CGFloat, L: Int, imageSet: [(String, UIImage)]) {
        
        let photoRingNode = SCNNode()
        //create a root node at camera node
        photoRingNode.position = SCNVector3Make(0, 0, 0)
        self.scene.rootNode.addChildNode(photoRingNode)
        //define the width, height, and radius of the photo
        let photoW: CGFloat = 1.4
        let photoH: CGFloat = photoW/0.618
        let radius: CGFloat = 0.2
        for index in 0..<L {
            //create a scnplane that holds the building image
            let photo = SCNPlane(width: photoW, height: photoH)
            photo.cornerRadius = radius
            let i = Int(index % imageSet.count)
            //get the building image
            let image = imageSet[i].1

            //assign the image to the diffuse content of node
            photo.firstMaterial?.diffuse.contents = image
            let photoNode = SCNNode(geometry: photo)
            photoNode.position = vector3
            photoNode.name = imageSet[i].0
            // photoRingNode.addChildNode(photoNode)
            let emptyNode = SCNNode()
            emptyNode.position = SCNVector3Make(0, 0, 0)
            //make the rotating photo equally distributed around user (360 degree / num of images)
            emptyNode.rotation = SCNVector4Make(0, 1, 0, (Float.pi/Float((Double(L)/Double(2)))) * Float(index))
            
            emptyNode.addChildNode(photoNode)

            photoRingNode.addChildNode(emptyNode)
        }

        let ringAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: left, z: 0, duration: 10))
        photoRingNode.runAction(ringAction)
    }
    func addPhotoRing_H(vector3: SCNVector3, left: CGFloat, L: Int, imageSet: [(String, UIImage)]) {

        let photoRingNode = SCNNode()
        //create a root node at camera node
        photoRingNode.position = SCNVector3Zero
        self.scene.rootNode.addChildNode(photoRingNode)
        //define the width, height, and radius of the photo
        let photoW: CGFloat       = 2.8
        let photoH: CGFloat       = photoW * 0.618
        let radius: CGFloat = 0.02
        for index in 0..<L {
            let photo = SCNPlane(width: photoW, height: photoH)
            photo.cornerRadius = radius
            let i = Int(index % imageSet.count)
            let image = imageSet[i].1
            //set the image to be the material of the node
            photo.firstMaterial?.diffuse.contents = image
            let photoNode = SCNNode(geometry: photo)
            photoNode.position = vector3
            photoNode.name = imageSet[i].0
            let emptyNode = SCNNode()
            emptyNode.position = SCNVector3Zero
            //make the rotating photo equally distributed around user (360 degree / num of images)
            emptyNode.rotation = SCNVector4Make(0, 1, 0, (Float.pi/Float((Double(L)/Double(2)))) * Float(index))
            emptyNode.addChildNode(photoNode)
            photoRingNode.addChildNode(emptyNode)
        }
        let ringAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: left, z: 0, duration: 10))
        photoRingNode.runAction(ringAction)
    }
    
}
