//
//  arBuildingView.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/27.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import SceneKit
import ARKit
/// Wrapper class to present a arBuildingController that shows the buildings in AR way
struct arBuildingRepresentable: UIViewControllerRepresentable {
   
    func makeUIViewController(context: Context) -> arBuildingController {
        let con = arBuildingController()
        con.sceneView = sceneView(frame: UIScreen.main.bounds)

        return con
    }
    func updateUIViewController(_ uiViewController: arBuildingController, context: Context) {
        //do nothing
    }
}
