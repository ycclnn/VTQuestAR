//
//  visitorNote.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/4.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import MapKit
import CoreData


/// The initial view user will see for VT Note tab view.
struct visitorNoteView: View {
    // ❎ Refresh this view upon notification that the managedObjectContext completed a save.
    // Upon refresh, @FetchRequest is re-executed fetching all Song entities with all the changes.
    @EnvironmentObject var userData: UserData
    //audio player that loads,plays,pauses an audio file
    @EnvironmentObject var audioPlayer: AudioPlayer
    //coredata context
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    //hide/show nav bar
    @State var hideNavBar = true
    //Map types
    var mapTypes = ["Standard", "Satellite", "Hybrid"]
    //show/hide the customized modal sheet
    @State private var bottomSheetShown = false
    //current selected map type
    @State var selectedMapTypeIndex = 0
    //show/hide the add a new note view
    @State var isPresented = false
    
    //show/hide the detail view of a note
    @State var annotationShow = false

    //latitude of VT campus
    @State var latitude = 37.227778

    //Longitude of VT campus
    @State var longitude = -80.422014
    
    // North-to-south and east-to-west distance from center
    @State var deltaLat = 1000.0
    @State var deltaLong = 1000.0
    @State var deltaUnit = "meters"
    
    //Note is nil until the callout of a note is tapped
    @State var noteItem: Note?
    
    
    var body: some View {
         NavigationView {
            ZStack {
                //hide the nav link until the map note callout is tapped
                //when noteItem is not nil, activate the nav link and go to the destination.
                if self.noteItem != nil && self.noteItem?.noteTitle != nil{
                NavigationLink(destination: noteCallOutDetail(noteId: (self.noteItem?.id!)!, hideNavBar: self.hideNavBar).environmentObject(self.audioPlayer)
                , isActive: self.$annotationShow) {
                    EmptyView()
                }
                }
                //this is the map view for visitor note view only
                mapViewForNote(mapType: self.type(index: self.selectedMapTypeIndex), latitude: self.latitude, longitude: self.longitude,
                              deltaLat: self.deltaLat, deltaLong: self.deltaLong, deltaUnit: self.deltaUnit, annotationTitle: "Virginia Tech").environment(\.managedObjectContext, managedObjectContext).edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Button(action: {
                                
                                self.bottomSheetShown.toggle()
                            }) {
                                Image(systemName: self.bottomSheetShown ? "info.circle.fill" : "info.circle")
                                  
                                    .font(Font.title.weight(.light))
                                    .foregroundColor(.blue)
                                    .padding(.top, 10)
                                    .padding(.bottom, 7)
                            }
                            
                            
                            Divider()
                            //Go to list view to display list
                            NavigationLink(destination: listNote(hidden: self.$hideNavBar)) {
                                Image(systemName: "list.bullet").font(Font.title.weight(.light))
                                   
                                    .foregroundColor(.blue)
                                    .padding(.top, 10)
                                    .padding(.bottom, 10)
                            }
                            
                            
                            Divider()
                            //go the add new note view
                            NavigationLink(destination: addNote().environment(\.managedObjectContext, managedObjectContext)) {
                                Image(systemName: "plus.circle").font(Font.title.weight(.light))
                                      
                                      .foregroundColor(.blue)
                                      .padding(.top, 7)
                                      .padding(.bottom, 10)
                            }

                        }
                        .frame(width: 40, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                        ).padding()
                    }
                    Spacer()
                }
                .padding(.bottom, 35)
                //Spacer()
                if (self.bottomSheetShown) {
                    GeometryReader { geometry in
                        BottomSheetView(
                            isOpen: self.$bottomSheetShown,
                            maxHeight: geometry.size.height * 0.32
                        ) {
                            // Color.blue
                            Divider()
                            Section(header: Text("Select Map Type").foregroundColor(Color.blue).bold().padding(.top, 10).padding(.bottom, 10)) {
                                Picker("Select Map Type", selection: self.$selectedMapTypeIndex) {
                                    ForEach(0 ..< self.mapTypes.count) { index in
                                        Text(self.mapTypes[index]).tag(index)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.leading, 15).padding(.trailing, 15)
                            }.padding(.top, 10)
                            
                        }.edgesIgnoringSafeArea(.all)
                        
                    }
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            
            .onAppear {
                //hide current view's nav bar because we want the map view to be shown in fullscreen
                self.hideNavBar = true
            }
            
         }.navigationViewStyle(StackNavigationViewStyle())

         .onReceive(noteDetailSender, perform: { (output: Note) in
            // Whenever publisher sends new value/note, old one to be replaced
            //This sender will let the detail view know and prepare the content for appropriate note that has been tapped
            self.noteItem = output
           

        })
         .onReceive(showCalloutDetailSender, perform: { (output: Bool) in
            //This will decide whether or not a detail of a note will be shown to the user
            self.annotationShow = output
         })
         

    }
    

    
    func type(index: Int) -> MKMapType {
        if (index == 0) {
            return MKMapType.standard
        }
        if (index == 1) {
            return MKMapType.satellite
        }
        else{
            return MKMapType.hybrid
        }
        
    }
}
//return the uiimage object by imageData input
func getImage(imageData: Data) -> UIImage {
    let imageReturned = UIImage(data: imageData)
    return imageReturned!
}
//search the database and find the entity of note with name "str"
func searchDatabaseForNote(id: UUID) -> Note {
   let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //The name of the building
    let query = id

    // ❎ Define the fetch request of note
    var noteFound = Note()
    let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
    
    // Note UUID contains queryTrimmed in case insensitive manner
    fetchRequest.predicate = NSPredicate(format: "id == %@", query as CVarArg)
    
    do {
        // ❎ Execute the fetch request
        //Single only single building is needed, we only retrieve the first element and there has to be only one element.
        noteFound = try managedObjectContext.fetch(fetchRequest)[0]
        
    } catch {
        print("Fetch Request Failed!")
    }
    //return the single note found by name.
    return noteFound
}
