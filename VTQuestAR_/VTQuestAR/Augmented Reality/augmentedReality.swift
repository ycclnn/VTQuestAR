//
//  imageTakenList.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/10.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import CoreData
import Combine


let showDeleteAlert = PassthroughSubject<Bool,Never>()


/// Used when applying more than one alert.
enum ActiveAlert {
    case first, second
}


struct augmentedReality: View {
    //default alert active is set up.
    @State private var activeAlert: ActiveAlert = .first

    //used to determine whether show/hide navigation bar
    @State var hide = true
    //used to detect tap gesture of taking pictures
    @State var didTapCapture: Bool = false
    //the custom nav bar item that is currently selected
    @State var selected = "arCamera"
    
    //select different Ar Hokies
    @State var selectArHokies = false
    
    //decide when to present an alert
    @State var showAlert = false
    
    
    //@State var arObject = -1
    //the instance of uiviewcontrollerrepresentable class
    let arHokieRepresentable = arViewControllerRepresentable()
    
    //@State var num = -1
    
    //core data context
    @Environment(\.managedObjectContext) var managedObjectContext
    
    //@State var arphotos = [UIImage]()
    //array that holds the fetch results of ArPhoto
    @State var ar = [ArPhoto]()
    //arPhoto fetch results
    @FetchRequest(fetchRequest: ArPhoto.allPhotosFetchRequest()) var photos: FetchedResults<ArPhoto>
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0){
                    ZStack{
                        HStack(spacing: 15){
                            
                            Button(action: {
                                
                                self.selected = "List"
                                
                            }) {
                                
                                VStack{
                                   //list icon
                                   Image(systemName: "list.bullet").font(.system(size: 19, weight: .regular))
                                       
                                        .foregroundColor(self.selected == "List" ? Color.blue : Color.black.opacity(0.2))
                                    
                                    
                                    //mark current icon as selected
                                    Circle().fill(self.selected == "List" ? Color.blue : Color.clear).frame(width: 5, height: 5).padding(.vertical,4)
                                }
                                
                                
                            }
                            Button(action: {
                                
                                self.selected = "carousel"
                                
                            }) {
                                
                                VStack{
                                    //carousel icon
                                   Image(systemName: "photo.on.rectangle").font(.system(size: 16, weight: .regular))
                                        .foregroundColor(self.selected == "carousel" ? Color.blue : Color.black.opacity(0.2))
                                    //mark carousel icon as selected
                                    Circle().fill(self.selected == "carousel" ? Color.blue : Color.clear).frame(width: 5, height: 5).padding(.vertical,4)
                                }
                                
                            }
                            Button(action: {
                                self.selected = "arCamera"

                            }) {
                                VStack {
                                    //camera icon
                                   Image(systemName: "camera.on.rectangle").font(.system(size: 16, weight: .regular))
                                        .foregroundColor(self.selected == "arCamera" ? Color.blue : Color.black.opacity(0.2))
                                    //Camera icon is marked as selected
                                    Circle().fill(self.selected == "arCamera" ? Color.blue : Color.clear).frame(width: 5, height: 5).padding(.vertical,4)
                                }
                            }

                        }
                        
  
                    }.frame(height: 50)
                    .padding(.horizontal)
                        .padding(.top, 5)
                    Divider()
                       
                    
                    //when current selected item is arCamera
                    if (self.selected == "arCamera") {
                        //display the UIs of camera view
                        ZStack(alignment: .bottom) {
                            //first add a arHokieRepresentable view
                            arHokieRepresentable
                            VStack{
                                //the button is used to select different AR hokie objects
                                Button(action: {
                                    //show the actionsheet that let user to select objects
                                    self.selectArHokies = true
                                   
                                    
                                    
                                }) {
                                    Image(systemName: "plus.circle").font(.system(size: 40, weight: .regular))
                                }

                                /*the photo capture button, when tapped, show the alert
                                 that the photo has been saved to the users.
                                */
                                CaptureButtonView().onTapGesture {
                                    
                                    self.showAlert = true
                                    self.activeAlert = .first
                                    
                                    /*derive the image capture on the user phone screen
                                     including Augmentd reality scene objects
                                     */
                                    let imageSaved = self.arHokieRepresentable.didTap()
                                    //self.arHokieRepresentable.resume()
                                  
                                   
                                    
                                    //get the core data context ready to use
                                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                                    
                                    //initialize a arPhoto entity
                                    guard let photoEntity = NSEntityDescription.insertNewObject(forEntityName: "ArPhoto", into: context) as? ArPhoto else {
                                      return
                                    }
                                    //assign png data to the photo entity
                                    photoEntity.photos = imageSaved.pngData()
                                    //date of photo captured
                                    let date = Date()
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    let datetime = dateFormatter.string(from: date)
                           
                                    //assign the date to the entity
                                    photoEntity.date = datetime
                             
                                    //assign the latitude to the entity showing where the image was taken
                                    photoEntity.lat = currentLocation().latitude as NSNumber?
                                   
                                    //assign the longitude to the entity showing where the image was taken
                                    photoEntity.long = currentLocation().longitude as NSNumber?
                                    
 
                                    do {
                                        //try to save the new photo into the coredata
                                        try context.save()
                                    
                                        
                                    } catch {
                                        //catch the error
                                        print("Error catched")
                                        return
                                    }

                                    
                                    let fetchRequest = NSFetchRequest<ArPhoto>(entityName: "ArPhoto")
                                    fetchRequest.sortDescriptors = []

                                    do {
                                        //update the ArPhoto list to display new content when capture is tapped.
                                        self.ar = try context.fetch(fetchRequest)
                                       

                                    }
                                    catch{
                                        print("Error")
                                    }
                                    
                                    
                                    
                                    
                                }.padding(.bottom,10)
                            }
                        }
                        

                        
                    }
                    //when nav item "carousel list" is selected
                    if (self.selected == "carousel") {
                        Carousel()
                       
                        
                    }
                    //when nav item "stacked list" is selected
                    if (self.selected == "List") {
                        arPhotoList(hide: self.$hide)
                    }
                    
                    
                    
                }
                
                if self.selectArHokies{
                    
                    GeometryReader{proxy in
                        
                        self.addOptions.position(.init(x: proxy.size.width / 2, y: proxy.size.height / 2))
                     
                    }.background(
                        
                        Color.black.opacity(0.65)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                
                                withAnimation{
                                    
                                    self.selectArHokies.toggle()
                                }
                            }
                        
                    )
                }

            }
            .navigationBarTitle("")
            .navigationBarHidden(self.hide)
          
            .onAppear() {
                self.hide = true
            }
            
           
        }.onReceive(showDeleteAlert, perform: { (output: Bool) in
            //when alert show signal is received, show the delete alert
            
            self.showAlert = output
            self.activeAlert = .second
            
            
            
        })
        
        //the action sheet to let user select ar objects
        //.actionSheet(isPresented: $selectArHokies, content: { arSettings })
        
        //two alert cases
        .alert(isPresented: $showAlert) {
                    switch activeAlert {
                    case .first:
                        return  Alert(title: Text("Photo Saved!"),
                                      
                                      dismissButton: .default(Text("OK")))
                    case .second:
                        return Alert(title: Text("Do you want to delete this object?"),
                                     primaryButton: .destructive(Text("Delete")) {
                                        self.arHokieRepresentable.remove()
                                     }, secondaryButton: .cancel()
                                     )
                    }
                }
        //hide the nav bar of this view, because the customized nav bar already be shown.
        .customNavigationViewStyle()
        //.navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    /// Present an alert asking user if he/she want to delete current selected object
    var deleteAlert: Alert {
        Alert(title: Text("Do you want to delete this AR object?"),
              primaryButton: .destructive(Text("Delete")) {
                
              }, secondaryButton: .cancel()
              )
    }
    var addOptions : some View{
        
        VStack(alignment: .center, spacing: 15) {
            HStack(spacing: 12){
                Text("Select an AR object!")
            }
            Divider().frame(width: 30, height: 1)
            Button(action: {
                self.arHokieRepresentable.addObject(type: 0)
                self.selectArHokies.toggle()
            }) {
                
                HStack(spacing: 12){
                   
                       
                    Text("VT Hokie").foregroundColor(.black)
                  
                    
                }
            }
            //Divider()
            Divider().frame(width: 30, height: 1)
            Button(action: {
                self.arHokieRepresentable.addObject(type: 3)
                self.selectArHokies.toggle()
            }) {
                
                HStack(spacing: 12){
                  
                    Text("VT Logo").foregroundColor(.black)
                    
                }
            }
            //Divider()
            Divider().frame(width: 30, height: 1)
            Button(action: {
                self.arHokieRepresentable.addObject(type: 2)
                self.selectArHokies.toggle()
            }) {
                
                HStack(spacing: 12){
                    
                   
                    Text("VT Truck").foregroundColor(.black)
                   
                }
            }
            //Divider()
            Divider().frame(width: 30, height: 1)
            Button(action: {
                self.arHokieRepresentable.addObject(type: 1)
                self.selectArHokies.toggle()
            }) {
                
                HStack(spacing: 12){
                    
                   
                    Text("VT Helmet").foregroundColor(.black).frame(alignment: .center)
                    
                }
            }
            
        }.padding()
        .background(Color.white)
        .cornerRadius(15)
    }

    var arSettings: ActionSheet {
        ActionSheet(
            title: Text("AR Objects"),
            message: Text("Select an AR object to be placed into world scene!"),
            buttons: [
                .default(Text("VT Hokie")) {
                    //tell the arscene to add a vt hokie
                    self.arHokieRepresentable.addObject(type: 0)
                    
                },
                .default(Text("VT Helmet")) {
                    //tell the arscene to add a vt helmet
                    self.arHokieRepresentable.addObject(type: 1)

                },
                .default(Text("VT Truck")) {
                    //tell the arscene to add a vt truck
                    self.arHokieRepresentable.addObject(type: 2)
                    
                },
                .default(Text("VT Logo")) {
                    //tell the arscene to add a vt logo
                    self.arHokieRepresentable.addObject(type: 3)
                    
                },
                .cancel() {
            
                    self.selectArHokies = false
                    
                }
        ])
    }
}

