//
//  ByName.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/23/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import SwiftUI
import CoreData

struct ByName: View {
    
    // ❎ CoreData managedObjectContext reference
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var searchFieldValue = ""
    @State private var searchFieldEmpty = false
    @State private var searchCompleted = false
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all)
        Form {
            Section(header: Text("Enter String contained in a building name")) {
                HStack {
                    TextField("Enter Search Query", text: $searchFieldValue)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button(action: {
                        self.searchFieldValue = ""
                        self.searchFieldEmpty = false
                        self.searchCompleted = false
                    }) {
                        Image(systemName: "multiply.circle")
                            .imageScale(.medium)
                            .font(Font.title.weight(.regular))
                    }
                    
                }   // End of HStack
                    .alert(isPresented: $searchFieldEmpty, content: { self.emptyAlert })
            }
            
            Section(header: Text("Search Database")) {
                HStack {
                    Button(action: {
                        // Remove spaces, if any, at the beginning and at the end of the entered search query string
                        let queryTrimmed = self.searchFieldValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if (queryTrimmed.isEmpty) {
                            self.searchFieldEmpty = true
                        } else {
                            self.searchDatabase()
                            self.searchCompleted = true
                        }
                    }) {
                        Text(self.searchCompleted ? "Search Completed" : "Search")
                    }
                    .frame(minWidth: 300, maxWidth: 500, maxHeight: 36, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.black, lineWidth: 1)
                    )
                }   // End of HStack
            }
            
            if searchCompleted {
                Section(header: Text("Show Buildings Found")) {
                    NavigationLink(destination: showSearchResults) {
                        Image(systemName: "list.bullet")
                            .imageScale(.medium)
                            .font(Font.title.weight(.regular))
                    }
                }
            }
            
        }   // End of Form
            .frame(minWidth: 300, maxWidth: 500, alignment: .center)
            .navigationBarTitle(Text("Search by Name"), displayMode: .inline)
            
        }   // End of ZStack
        
    }   // End of body
    
    func searchDatabase() {
        
        // Remove spaces, if any, at the beginning and at the end of the entered search query string
        let queryTrimmed = self.searchFieldValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Initialize the global variable declared in BuildingData.swift
        foundBuildingsList = [Building]()
        
        // ❎ Define the fetch request
        let fetchRequest = NSFetchRequest<Building>(entityName: "Building")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Building name contains queryTrimmed in case insensitive manner
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", queryTrimmed)
        
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
    
    var emptyAlert: Alert {
        Alert(title: Text("Search Field is Empty!"),
              message: Text("Please enter a search query!"),
              dismissButton: .default(Text("OK")))
    }

}

struct ByName_Previews: PreviewProvider {
    static var previews: some View {
        ByName()
    }
}
