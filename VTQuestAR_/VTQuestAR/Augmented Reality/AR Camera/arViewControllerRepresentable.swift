//
//  test.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/3.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import AVFoundation
import UIKit

/// the wrapper class to use ARSCNView in SwiftUI
struct arViewControllerRepresentable: UIViewControllerRepresentable {

    
    /// declare the view controller class
    var controller = ArViewController()
    
    
    /// tells the view controller to add an ar object of types
    /// - Parameter type: 0:  hokie; 1: helmet; 2: truck; 3: logo
    func addObject(type: Int){
        //make a call to function in ArViewController class
        controller.addARObject(type: type)
    }
    
    
    ///  when capture button is tapped
    /// - Returns: return the screenshot of current frame of ARSCNView
    func didTap() -> UIImage{
        return (controller.didTapRecord())
    }
    //when user want to delete a ar object in the ar scene.
    func remove() {
        controller.removeNode()
    }
    
    func makeUIViewController(context: Context) -> ArViewController {
        return controller

    }
    func updateUIViewController(_ uiViewController: ArViewController, context: Context) {

    }
}

