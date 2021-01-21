


//
//  nodeAnnotation.swift
//  firstdemo
//
//  Created by zhennan on 2020/3/29.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import UIKit
import CoreLocation
import SpriteKit
import SwiftUI
import Foundation

struct nodeAnnotationView: UIViewRepresentable {
  
    var title: String
   
    func makeUIView(context: Context) -> nodeAnnotation {
        return nodeAnnotation(frame: CGRect(), identifier: UUID(), title: title)
    }
    func updateUIView(_ uiView: nodeAnnotation, context: Context) {
        
    }
}

class nodeAnnotation: UIView {
    //annotation identifier
    var identifier: UUID?
    //annotation title
    var title: String = "Title"
    
    
    //set up the annotation parameters
    init(frame: CGRect, identifier: UUID, title: String) {
        
        super.init(frame: frame)
        self.identifier = identifier
        self.title = title
        self.backgroundColor = UIColor.lightGray

       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    
    
}



