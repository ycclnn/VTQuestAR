//
//  ARViewContainer.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/18.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import UIKit
import SpriteKit
import ARKit
import CoreLocation

//instance of arskview that will be used to place green pins(ar nodes) on.
public var arView = ARSKView()

//ARView container that holds the green pins.
struct ARViewContainer: UIViewRepresentable {
    //SKScene of the SKView
    let scene : SKScene
    
    //Two modes: AR and ML, will show different UIs depends on the mode
    @Binding var mode: String
    
    func makeCoordinator() -> ARViewContainer.Coordinator {
        Coordinator(self)
    }
   
    func makeUIView(context: Context) -> ARSKView {
        
        //set up the frame to cover the screen space
        arView = ARSKView(frame: .zero)
        arView.delegate = context.coordinator
        
        //set up the ar configuration
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading
        
        
        config.isLightEstimationEnabled = true
        arView.session.run(config)
        
        arView.presentScene(scene)
       
        
        return arView
    }
    func updateUIView(_ uiView: ARSKView, context: Context) {
        uiView.scene?.scaleMode = .resizeFill
        
    }
    
    
    
    class Coordinator: NSObject, ARSKViewDelegate {
        
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
            super.init()
            //send the notification to remove all noedes
            NotificationCenter.default.addObserver(self, selector: #selector(removeNodes), name: Notification.Name("shouldRemoveNodes"), object: nil)
        }
       
        //remove al nodes and actions from the ARScene
        @objc func removeNodes() {
            
            arView.scene?.removeAllChildren()
            let config = ARWorldTrackingConfiguration()
            config.worldAlignment = .gravityAndHeading
            arView.session.run(config, options: [ .resetTracking, .resetSceneReconstruction, .removeExistingAnchors])

            
            
            
        }
        func displayARItems(_ location: CLLocation) -> Int {
            return 1
        }
        
        func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
           
            //if mode is AR, add a SKNode to the ARAnchor in 3d world scene. ARAnchor has x, y, z coordinate in 3d space, in order to add a node, we have to have ARAnchors.
           
            if (parent.mode == "AR") {
                
                let annots = annotations.filter{
                    $0.identifier! == anchor.identifier
                }
                
                //if at least one annotation existing
                if annots.count > 0 {
                    
                    let annot = annots.first

                    let texture = SKTexture(imageNamed: "pp")
                  
                   // texture.image
                    let sprite = SKSpriteNode(texture: texture)
                  
                    sprite.name = annot?.title
                    //return the green pin to add it to the AR scene
                    return sprite
                  
                }
            }
            
            return nil
            
            
            
            
        }
       
        
        
    }
    
}
