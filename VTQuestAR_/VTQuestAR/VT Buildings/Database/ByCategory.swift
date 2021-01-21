//
//  ByCategory.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/23/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import SwiftUI
import CoreData

struct ByCategory: View {
    
    // ❎ CoreData managedObjectContext reference
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var selectedCategoryIndex = Int(vtBuildingCategories.count/2)
    @State private var searchCompleted = false
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all)
        Form {
            Section(header: Text("Select a Building Category")) {
                Picker("", selection: $selectedCategoryIndex) {
                    ForEach(0 ..< vtBuildingCategories.count, id: \.self) {
                        Text(vtBuildingCategories[$0])
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
            Section(header: Text("Search Database")) {
                HStack {
                    Button(action: {
                        self.searchDatabase()
                        self.searchCompleted = true
                    }) {
                        Text(self.searchCompleted ? "Search Completed" : "Search")
                    }
                    .frame(minWidth: 300, maxWidth: 500, maxHeight: 36, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.black, lineWidth: 1)
                    )
                }
            }
            
            if searchCompleted {
                Section(header: Text("Show Buildings Found")) {
                    NavigationLink(destination: showSearchResults) {
                        Image(systemName: "list.bullet")
                            .imageScale(.medium)
                            .font(Font.title.weight(.regular))
                    }
                }
                Section(header: Text("Clear to Search Again")) {
                    Button(action: {
                        self.searchCompleted = false
                    }) {
                        Text("Clear")
                    }
                    .frame(width: 100, height: 36, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.black, lineWidth: 1)
                    )
                }
            }
            
        }   // End of Form
            .frame(minWidth: 300, maxWidth: 500, alignment: .center)
            .navigationBarTitle(Text("Search by Category"), displayMode: .inline)
            
        }   // End of ZStack
        
    }   // End of body
    
    func searchDatabase() {
                
        // Initialize the global variable declared in BuildingData.swift
        foundBuildingsList = [Building]()
        
        // ❎ Define the fetch request
        let fetchRequest = NSFetchRequest<Building>(entityName: "Building")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Building category matches the selection
        fetchRequest.predicate = NSPredicate(format: "category == %@", vtBuildingCategories[self.selectedCategoryIndex])
        
        do {
            // ❎ Execute the fetch request
            foundBuildingsList = try self.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("Fetch Request Failed!")
        }
    }
    
    var showSearchResults: some View {
        
        if foundBuildingsList.isEmpty {
            return AnyView(NotFoundMessage())
        }
        return AnyView(SearchResultsList())
    }

}

struct ByCategory_Previews: PreviewProvider {
    static var previews: some View {
        ByCategory()
    }
}
