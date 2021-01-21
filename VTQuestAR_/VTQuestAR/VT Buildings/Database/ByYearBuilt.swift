//
//  ByYearBuilt.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/23/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import SwiftUI
import CoreData

struct ByYearBuilt: View {
    
    // ❎ CoreData managedObjectContext reference
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var searchFieldValue = 0
    @State private var invalidYearEntered = false
    @State private var searchCompleted = false
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all)
        Form {
            Section(header: Text("Enter year a building was built")) {
                HStack {
                    TextField("Enter Search Query", value: $searchFieldValue, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numbersAndPunctuation)
                    
                    Button(action: {
                        self.searchFieldValue = 0
                        self.invalidYearEntered = false
                        self.searchCompleted = false
                    }) {
                        Image(systemName: "multiply.circle")
                            .imageScale(.medium)
                            .font(Font.title.weight(.regular))
                    }
                    
                }   // End of HStack
                    .alert(isPresented: $invalidYearEntered, content: { self.invalidYearAlert })
            }
            Section(header: Text("Search Database")) {
                HStack {
                    Button(action: {
                        if (1872...self.currentYear()).contains(self.searchFieldValue) {
                            self.searchDatabase()
                            self.searchCompleted = true
                        } else {
                            self.invalidYearEntered = true
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
            .navigationBarTitle(Text("Search by Year Built"), displayMode: .inline)
            
        }   // End of ZStack
        
    }   // End of body
    
    func searchDatabase() {
        
        // Initialize the global variable declared in BuildingData.swift
        foundBuildingsList = [Building]()
        
        // ❎ Define the fetch request
        let fetchRequest = NSFetchRequest<Building>(entityName: "Building")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // The year building was built matches the year entered
        fetchRequest.predicate = NSPredicate(format: "yearBuilt == %i", self.searchFieldValue)
        
        do {
            // ❎ Execute the fetch request
            foundBuildingsList = try self.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("Fetch Request Failed!")
        }
    }
    
    func currentYear() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        return components.year!
    }
    
    var showSearchResults: some View {
        
        if foundBuildingsList.isEmpty {
            return AnyView(NotFoundMessage())
        }
        return AnyView(SearchResultsList())
    }
    
    var invalidYearAlert: Alert {
        Alert(title: Text("Year Entered is Invalid!"),
              message: Text("Please enter a valid year!"),
              dismissButton: .default(Text("OK")))
    }
}

struct ByYearBuilt_Previews: PreviewProvider {
    static var previews: some View {
        ByYearBuilt()
    }
}
