//
//  arBuilding.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/27.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit
import Combine

/// Image sets for eight different categories, storing the tuples. First element of tuple is image file name, second element is its uiimage data.
var academicImageSet = [(String, UIImage)]()
var supportImageSet = [(String, UIImage)]()
var residenceDiningImageSet = [(String, UIImage)]()
var administrationImageSet = [(String, UIImage)]()
var athleticImageSet = [(String, UIImage)]()
var diningImageSet = [(String, UIImage)]()
var researchImageSet = [(String, UIImage)]()
var residenceImageSet = [(String, UIImage)]()
let buildingNameSender = PassthroughSubject<Building, Never>()
let showHideSender = PassthroughSubject<Bool, Never>()
class arBuildingController: UIViewController,ARSCNViewDelegate {

    
    /// UI Stack view that organize eight categories
    var stackView = UIStackView()
    
    /// back button to go back to previous view
    let backButton = UIButton(frame: CGRect(x:0, y:0, width: 40, height:  40))
    
    /// AR scene view
    var sceneView: sceneView!
   
    
    
    /// current selected node in AR scene
    var selectNode: SCNNode?
    
    
    //load all images into eight sub category arrays
    func loadImages(buildingSet: [Building]) -> [(String, UIImage)] {
        var imageSetTem = [(String, UIImage)]()
        for aBuilding in buildingSet {
            let image = UIImage(named: aBuilding.imageFilename!)
            let name = aBuilding.name!
            imageSetTem.append((name, image!))

        }
        return imageSetTem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set the image of the back button to be the left arrow indicating user can go back to previous view
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.imageEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        backButton.center.y = self.view.center.y
        backButton.backgroundColor = .clear
        backButton.tintColor = .blue
        backButton.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.width/2
        backButton.layer.borderColor = UIColor.white.cgColor
        backButton.layer.borderWidth  = 2
        self.view.addSubview(backButton)
        backButton.isHidden = true
        backButton.addTarget(self, action: #selector(backbuttonTapped(sender:)), for: UIControl.Event.touchUpInside)
        
        let configuration = ARWorldTrackingConfiguration()
        //load all images into arrays
        sceneView.session.run(configuration)
        academicImageSet = loadImages(buildingSet: academic)
        supportImageSet = loadImages(buildingSet: support)
        residenceDiningImageSet = loadImages(buildingSet: residentDining)
        administrationImageSet = loadImages(buildingSet: administration)
        athleticImageSet = loadImages(buildingSet: athletic)
        diningImageSet = loadImages(buildingSet: dining)
        researchImageSet = loadImages(buildingSet: research)
        residenceImageSet = loadImages(buildingSet: resident)


        //set up the stackview
        stackView = UIStackView(frame: CGRect(x:0, y:0, width: self.view.frame.size.width/2, height: self.view.frame.size.height/2))
        //customize the stackview
        stackView.customize()
        //make the stackview center aligned
        stackView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)

        stackView.layer.cornerRadius = 30
        stackView.axis = .vertical
       
        stackView.distribution = .fillEqually

        //button 0 that let the users browse buildings in AR of category: Academic
        let button0 = UIButton(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/16))

        button0.setTitle("Academic", for: .normal)
        button0.layer.borderColor = UIColor.black.cgColor
        button0.layer.borderWidth  = 1.0
        button0.setTitleColor(.black, for: .normal)
        button0.addTarget(self, action: #selector(buttonTapped(sender:)), for: UIControl.Event.touchUpInside)

        //button 1 that let the users browse buildings in AR of category: support
        let button1 = UIButton(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/16))
        button1.setTitle("support", for: .normal)
        button1.layer.borderColor = UIColor.black.cgColor
        button1.layer.borderWidth  = 1.0
        button1.setTitleColor(.black, for: .normal)
        
        //button 2 that let the users browse buildings in AR of category: residence and dining
        let button2 = UIButton(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/16))
        button2.setTitle("Residence And Dining", for: .normal)
        button2.layer.borderColor = UIColor.black.cgColor
        button2.layer.borderWidth  = 1.0
        button2.setTitleColor(.black, for: .normal)
        
        //button 3 that let the users browse buildings in AR of category: Administration
        let button3 = UIButton(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/16))
        button3.setTitle("Administration", for: .normal)
        button3.layer.borderColor = UIColor.black.cgColor
        button3.layer.borderWidth  = 1.0
        button3.setTitleColor(.black, for: .normal)
        let button4 = UIButton(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/16))
        //button 4 that let the users browse buildings in AR of category: athletic
        button4.setTitle("Athletic", for: .normal)
        button4.layer.borderColor = UIColor.black.cgColor
        button4.layer.borderWidth  = 1.0
        button4.setTitleColor(.black, for: .normal)
        //button 5 that let the users browse buildings in AR of category: dining
        let button5 = UIButton(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/16))
        button5.setTitle("Dining", for: .normal)
        button5.layer.borderColor = UIColor.black.cgColor
        button5.layer.borderWidth  = 1.0
        button5.setTitleColor(.black, for: .normal)
        //button 6 that let the users browse buildings in AR of category: research
        let button6 = UIButton(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/16))
        button6.setTitle("Research", for: .normal)
        button6.layer.borderColor = UIColor.black.cgColor
        button6.layer.borderWidth  = 1.0
        button6.setTitleColor(.black, for: .normal)
        let button7 = UIButton(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/16))
        //button 7 that let the users browse buildings in AR of category: residence
        button7.setTitle("Residence", for: .normal)
        button7.layer.borderColor = UIColor.black.cgColor
        button7.layer.borderWidth  = 1.0
        button7.setTitleColor(.black, for: .normal)
        
        //add all buttons into the stackview
        stackView.addArrangedSubview(button0)
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        stackView.addArrangedSubview(button3)
        stackView.addArrangedSubview(button4)
        stackView.addArrangedSubview(button5)
        stackView.addArrangedSubview(button6)
        stackView.addArrangedSubview(button7)
        //add all buttons tap behavior
        button1.addTarget(self, action: #selector(buttonTapped1(sender:)), for: UIControl.Event.touchUpInside)
        button2.addTarget(self, action: #selector(buttonTapped2(sender:)), for: UIControl.Event.touchUpInside)
        button3.addTarget(self, action: #selector(buttonTapped3(sender:)), for: UIControl.Event.touchUpInside)
        button4.addTarget(self, action: #selector(buttonTapped4(sender:)), for: UIControl.Event.touchUpInside)
        button5.addTarget(self, action: #selector(buttonTapped5(sender:)), for: UIControl.Event.touchUpInside)
        button6.addTarget(self, action: #selector(buttonTapped6(sender:)), for: UIControl.Event.touchUpInside)
        button7.addTarget(self, action: #selector(buttonTapped7(sender:)), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(stackView)
       
    }
    //if back buttont tapped, remove all nodes, set back button to hidden, and show the stackview again.
    @objc func backbuttonTapped(sender: UIButton) {
        sceneView.removeAllNodes()
        backButton.isHidden = true
        stackView.isHidden = false
        showHideSender.send(false)
        
    }
    
    //button 0 tapped, display academic buildings in AR
    @objc func buttonTapped(sender: UIButton) {

        self.stackView.isHidden = true
      
        backButton.isHidden = false
        
        sceneView.removeAllNodes()

       
        sceneView.addPhotoRing_V(vector3: SCNVector3Make(0, 1.5, -6), left: -1, L: 20, imageSet: academicImageSet)
        sceneView.addPhotoRing_H(vector3: SCNVector3Make(0, -1, -6), left: 1, L: 10, imageSet: Array(academicImageSet[20...29]))
        sceneView.addPhotoRing_V(vector3: SCNVector3Make(0, -3.5, -6), left: -1, L: 17, imageSet: Array(academicImageSet[30...46]))

        }

    //button 1 tapped, display support buildings in AR
    @objc func buttonTapped1(sender: UIButton) {
          
        self.stackView.isHidden = true
      
        backButton.isHidden = false
        
        sceneView.removeAllNodes()
        sceneView.addPhotoRing_V(vector3: SCNVector3Make(0, 1.5, -6), left: -1, L: 20, imageSet: supportImageSet)
        sceneView.addPhotoRing_H(vector3: SCNVector3Make(0, -1, -6), left: 1, L: 8, imageSet: Array(supportImageSet[20...27]))
        
        }
    //button 2 tapped, display residence buildings in AR
    @objc func buttonTapped2(sender: UIButton) {
           
        self.stackView.isHidden = true
      
        backButton.isHidden = false
        
        sceneView.removeAllNodes()
        sceneView.addPhotoRing_V(vector3: SCNVector3Make(0, 1.5, -6), left: -1, L: 16, imageSet: residenceDiningImageSet)
       
        }
    //button 3 tapped, display administration buildings in AR
    @objc func buttonTapped3(sender: UIButton) {
           
        self.stackView.isHidden = true
      
        backButton.isHidden = false
        
        sceneView.removeAllNodes()
        sceneView.addPhotoRing_V(vector3: SCNVector3Make(0, 1.5, -6), left: -1, L: 5, imageSet: administrationImageSet)
        }
    //button 4 tapped, display athletic buildings in AR
    @objc func buttonTapped4(sender: UIButton) {
          
        self.stackView.isHidden = true
      
        backButton.isHidden = false
        
        sceneView.removeAllNodes()
        sceneView.addPhotoRing_V(vector3: SCNVector3Make(0, 1.5, -6), left: -1, L: 10, imageSet: athleticImageSet)
        }
    //button 5 tapped, display dining buildings in AR
    @objc func buttonTapped5(sender: UIButton) {
          
        self.stackView.isHidden = true
      
        backButton.isHidden = false
        
        sceneView.removeAllNodes()
        sceneView.addPhotoRing_V(vector3: SCNVector3Make(0, 1.5, -6), left: -1, L: 2, imageSet: diningImageSet)
        }
    //button 6 tapped, display research buildings in AR
    @objc func buttonTapped6(sender: UIButton) {
          
        self.stackView.isHidden = true
      
        backButton.isHidden = false
        
        sceneView.removeAllNodes()
        sceneView.addPhotoRing_V(vector3: SCNVector3Make(0, 1.5, -6), left: -1, L: 7, imageSet: researchImageSet)
        }
    //button 0 tapped, display residence buildings in AR
    @objc func buttonTapped7(sender: UIButton) {
        
        self.stackView.isHidden = true
      
        backButton.isHidden = false
        
        sceneView.removeAllNodes()
        sceneView.addPhotoRing_V(vector3: SCNVector3Make(0, 1.5, -6), left: -1, L: 7, imageSet: residenceImageSet)
        }
    //upon disppear, remove all node from AR view and remove all UI view.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        backButton.isHidden = true
        stackView.isHidden = false
        sceneView.removeAllNodes()
        stackView.removeFromSuperview()
        backButton.removeFromSuperview()
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.addSubview(sceneView)
        
        sceneView.delegate = self
        //antialiasing
        sceneView.antialiasingMode = .multisampling4X
        

      
    }


    //whenever a building image in AR view is tapped, display its detail such as building name, type, description, etc.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
            if(touch.view == self.sceneView){
                
                let viewTouchLocation:CGPoint = touch.location(in: sceneView)
                guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {
                    
                    return
                }
                //first search the building in the database
                let building = searchDatabase(str: result.node.name!)
                //send out output
                buildingNameSender.send(building)
                showHideSender.send(true)

            }
        }

}


//customize the UIStackView
extension UIStackView {
    func customize(backgroundColor: UIColor = UIColor(red: 227 / 255, green: 225 / 255, blue: 222 / 255, alpha: 0.7), radiusSize: CGFloat = 0) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = backgroundColor
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)

        subView.layer.cornerRadius = radiusSize
        subView.layer.masksToBounds = true
        subView.clipsToBounds = true
    }
}
