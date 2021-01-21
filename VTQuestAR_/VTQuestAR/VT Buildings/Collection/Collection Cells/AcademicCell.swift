//
//  AcademicCell.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/3.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import UIKit
//set up layout constraint, title, and image for academic cell.

class AcademicCell: UICollectionViewCell {
    
    func setBuildingNameAndImage(building:Building) {
        imageView.image = UIImage(named: building.imageFilename!)
        buildingNameLabel.text = building.name
    }
  
   var imageView = UIImageView()
   
    
    var buildingNameLabel = UILabel()
     
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //set up the image view
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.clipsToBounds = true
        
        imageView.layer.cornerRadius = 10
        
        //set up the building name label
        buildingNameLabel.text = "TBD"
        
        buildingNameLabel.translatesAutoresizingMaskIntoConstraints = false
        buildingNameLabel.numberOfLines = 2
        buildingNameLabel.textColor = .white
        buildingNameLabel.font = .boldSystemFont(ofSize: 18)
        contentView.addSubview(self.imageView)
        contentView.addSubview(buildingNameLabel)
        
        //activate all the following autolayout constraint
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9).isActive = true
        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1).isActive = true
        buildingNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10).isActive = true
        buildingNameLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        buildingNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        buildingNameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
      
    } 
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}



