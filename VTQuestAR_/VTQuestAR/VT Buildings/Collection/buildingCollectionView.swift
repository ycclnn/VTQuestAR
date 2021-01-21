//
//  buildingCollectionView.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/3.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import Foundation
import UIKit
import Combine

//building categories
var categories = ["Academic", "Support", "Residence and Dining Halls", "Administration", "Athletic", "Dining", "Research", "Residence"]
//current section
var sectionSender = CurrentValueSubject<Int, Never>(-1)

//var sectionSender = -1
//a building instance
var buildingSender = Building()
//This class is to set up the collection view to display buildings.
struct buildingCollectionView: UIViewRepresentable {
 
    //see all button tapped/not tapped
    @Binding var showSeeAll: Bool
    //show/not show a single building
    @Binding var showSingleBuilding: Bool
  
    //a single building is selected, show its detail

    func didSelectItem(indexP: IndexPath) {
        buildingSender = buildingListWithCategories[categories[indexP.section]]![indexP.item]
        self.showSingleBuilding = true
       
    }
    //make the UIViewRepresentable to its coordinator
    func makeCoordinator() -> buildingCollectionView.Coordinator {
        Coordinator(self)
    }
    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: context.coordinator.initializeCollectionViewLayout())
        collectionView.backgroundColor = .white
        
        //Register eight collection cells
        collectionView.register(AcademicCell.self, forCellWithReuseIdentifier: "AcademicCell")
        
        //
        collectionView.register(SupportCell.self, forCellWithReuseIdentifier: "SupportCell")
        //
        collectionView.register(ResidenceAndDiningCell.self, forCellWithReuseIdentifier: "ResidenceAndDiningCell")
        //
        collectionView.register(AdministrationCell.self, forCellWithReuseIdentifier: "AdministrationCell")
        //
        collectionView.register(AthleticCell.self, forCellWithReuseIdentifier: "AthleticCell")
        //
        collectionView.register(DiningCell.self, forCellWithReuseIdentifier: "DiningCell")
        //
        collectionView.register(ResearchCell.self, forCellWithReuseIdentifier: "ResearchCell")
        //
        collectionView.register(ResidenceCell.self, forCellWithReuseIdentifier: "ResidenceCell")
        
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: "HeaderView")
        
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        
        return collectionView
    }
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        
        var parent: buildingCollectionView
        
        init(_ parent: buildingCollectionView) {
            self.parent = parent
        }
        
        //the number of buildings in each section
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return buildingListWithCategories[categories[section]]!.count
            
        }
        
        //the number of sections/building categories
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return buildingListWithCategories.count
        }
        //Asks your data source object to provide a reusable supplementary view (header view to display in the collection view. In our case, a header view is a view displaying building category names and "see all" button such as "Academic" on the left and "See all" on the right.
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as? HeaderView
                header!.name.text = categories[indexPath.section]
                //assign the tag with section id such that when seeAll button gets tapped, we can determine which category to display.
                header!.seeAllButton.tag = indexPath.section
                return header!
            }
                else{
                return UICollectionReusableView()
            }
        }
     
        //Asks data source object for the cell that corresponds to the specified item in the collection view.
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            switch indexPath.section {
            //eight difference cell will be returned and added to the view
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AcademicCell", for: indexPath) as? AcademicCell
                else{ fatalError("Could not create cells")}
//                    cell.academic = (buildingListWithCategories["Academic"]?[indexPath.item])! as Building
                cell.setBuildingNameAndImage(building: (buildingListWithCategories["Academic"]?[indexPath.item])! as Building)
                    return cell
                
            case 1:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SupportCell", for: indexPath) as? SupportCell
                else{ fatalError("Could not create cells")}
                   
                cell.setBuildingNameAndImage(building: (buildingListWithCategories["Support"]?[indexPath.item])! as Building)
               
                    return cell
                
            case 2:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResidenceAndDiningCell", for: indexPath) as? ResidenceAndDiningCell
                else{ fatalError("Could not create cells")}
               
                cell.setBuildingNameAndImage(building: (buildingListWithCategories["Residence and Dining Halls"]?[indexPath.item])! as Building)
                    return cell
                
                
            case 3:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdministrationCell", for: indexPath) as? AdministrationCell
                else{ fatalError("Could not create cells")}
                   
                cell.setBuildingNameAndImage(building: (buildingListWithCategories["Administration"]?[indexPath.item])! as Building)
                    return cell
                
            case 4:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AthleticCell", for: indexPath) as? AthleticCell
                else{ fatalError("Could not create cells")}
                cell.setBuildingNameAndImage(building: (buildingListWithCategories["Athletic"]?[indexPath.item])! as Building)
                   
                    return cell
                
            case 5:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiningCell", for: indexPath) as? DiningCell
                else{ fatalError("Could not create cells")}
              
                cell.setBuildingNameAndImage(building: (buildingListWithCategories["Dining"]?[indexPath.item])! as Building)
                    return cell
                
            case 6:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResearchCell", for: indexPath) as? ResearchCell
                else{ fatalError("Could not create cells")}
                    
                cell.setBuildingNameAndImage(building: (buildingListWithCategories["Research"]?[indexPath.item])! as Building)
                    return cell
                
            default:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResidenceCell", for: indexPath) as? ResidenceCell
                else{ fatalError("Could not create cells")}
                
                cell.setBuildingNameAndImage(building: (buildingListWithCategories["Residence"]?[indexPath.item])! as Building)
                    return cell

            }
        }
        //Tells the delegate that the item at the specified index path was selected.
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            //call didselectitem func to display the building detail
            parent.didSelectItem(indexP: indexPath)
            
        }
        //set up the layout for section which display two building at a time stacking horizontally while scrolling horizontally. For example, "Support" type.
        func createTwoBuildingHorizontalSectionLayout() -> NSCollectionLayoutSection {
          
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
      
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95), heightDimension:  .fractionalWidth(0.75)), subitems: [item])
            let layoutSection = NSCollectionLayoutSection(group: nestedGroup)
            layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
            layoutSection.boundarySupplementaryItems = [createSectionHeader()]
            return layoutSection
        }
        //set up the layout for section which display four building at a time stacking horizontally while scrolling horizontally. For example, "Residence and Dining halls" type.
        func createFourBuildingSection() -> NSCollectionLayoutSection {

            let firstItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
            firstItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            let firstLayoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension:  .fractionalWidth(1)), subitems: [firstItem])
            

            let secondLayoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension:  .fractionalWidth(1)), subitems: [firstItem])
            
            let combineGroup = NSCollectionLayoutGroup.horizontal(
              layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.95),
                heightDimension: .fractionalWidth(1)),
              subitems: [firstLayoutGroup, secondLayoutGroup])
            
            
            let layoutSection = NSCollectionLayoutSection(group: combineGroup)
            layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
            layoutSection.boundarySupplementaryItems = [createSectionHeader()]
            return layoutSection
        }
        //set up the layout for section which display one building at a time while scrolling horizontally. For example, "Academic" type.
        func createOneBuildingSectionLayout() -> NSCollectionLayoutSection {
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension:  .fractionalWidth(0.5)), subitems: [item])
            let layoutSection = NSCollectionLayoutSection(group: nestedGroup)
            //make some room for the last section
            layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 3, trailing: 0)
            layoutSection.orthogonalScrollingBehavior = .groupPaging
            layoutSection.boundarySupplementaryItems = [createSectionHeader()]
            return layoutSection
        }
        //create the section header that contains building category and seeAll button
        func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
            let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70))
            let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            return layoutSectionHeader
        }
        //create and return corresponding compositional layouts
        func initializeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
            let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
                layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                switch sectionIndex {
                //eight difference cell will be returned and added to the view
                case 0:
                    return self.createOneBuildingSectionLayout()
                case 1:
                    return self.createTwoBuildingHorizontalSectionLayout()
                case 2:
                    return self.createFourBuildingSection()
                    
                case 3:
                    return self.createOneBuildingSectionLayout()
                case 4:
                    return self.createTwoBuildingHorizontalSectionLayout()
                case 5:
                    return self.createOneBuildingSectionLayout()
                case 6:
                    return self.createFourBuildingSection()
                default:
                    return self.createOneBuildingSectionLayout()
                    
                }
                
            }
            let configuration = UICollectionViewCompositionalLayoutConfiguration()
            configuration.interSectionSpacing = 14
            layout.configuration = configuration
            return layout
        }
    }
    
}
