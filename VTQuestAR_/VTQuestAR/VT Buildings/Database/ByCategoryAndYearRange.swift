//
//  ByCategoryAndYearRange.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/23/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import SwiftUI
import CoreData

struct ByCategoryAndYearRange: View {
    
    // Subscribe to changes in UserData
    @EnvironmentObject var userData: UserData
    
    // ❎ CoreData managedObjectContext reference
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var selectedCategoryIndex = Int(vtBuildingCategories.count/2)
    @State private var searchFieldValueLow = 0
    @State private var searchFieldValueHigh = 0
    @State private var invalidYearEntered = false
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
            Section(header: Text("Enter lowest year a building was built")) {
                HStack {
                    TextField("Enter Search Query", value: $searchFieldValueLow, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numbersAndPunctuation)
                    
                    Button(action: {
                        self.searchFieldValueLow = 0
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
            Section(header: Text("Enter highest year a building was built")) {
                HStack {
                    TextField("Enter Search Query", value: $searchFieldValueHigh, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numbersAndPunctuation)
                    
                    Button(action: {
                        self.searchFieldValueHigh = 0
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
                        if self.searchFieldValueHigh >= self.searchFieldValueLow {
                            if (1872...self.currentYear()).contains(self.searchFieldValueLow) && (1872...self.currentYear()).contains(self.searchFieldValueHigh) {
                                self.searchDatabase()
                                self.searchCompleted = true
                            } else {
                                self.invalidYearEntered = true
                            }
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
            .navigationBarTitle(Text("Search by Category and Year Range"), displayMode: .inline)
            
            
        }   // End of ZStack
        
    }   // End of body
    
    func searchDatabase() {
        
        // Initialize the global variable declared in BuildingData.swift
        foundBuildingsList = [Building]()
        
        // ❎ Define the fetch request
        let fetchRequest = NSFetchRequest<Building>(entityName: "Building")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Year building was built falls within the year range entered under the selected category
        fetchRequest.predicate = NSPredicate(format: "category == %@ AND yearBuilt >= %i AND yearBuilt <= %i", vtBuildingCategories[self.selectedCategoryIndex], self.searchFieldValueLow, self.searchFieldValueHigh)
        
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

struct ByCategoryAndYearRange_Previews: PreviewProvider {
    static var previews: some View {
        ByCategoryAndYearRange()
    }
}
