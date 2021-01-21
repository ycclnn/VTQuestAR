//
//  Carousel.swift
//  VTQuestAR
//
//  Created by zhennan on 2020/7/17.
//

import SwiftUI
/// the single photo that user taps on
var photoTapped = arPhotoCarousel()

struct Carousel : View {
    
//    /// the single photo that user taps on
//    @State var photoTapped = arPhotoCarousel()
    
    /// core data context
    @Environment(\.managedObjectContext) var managedObjectContext
    
    /// Fetch result of all arPhotos in coredata model
    @FetchRequest(fetchRequest: ArPhoto.allPhotosFetchRequest()) var photos: FetchedResults<ArPhoto>

    /// show the alert about whether or not to delete a certain image
    @State var showAlert = false
    
    
    /// UI constraint used to create the custom carousel list
    @State var index : Int = 0
    @State var carouselOffset : CGFloat = 0

    @State var hStackOffset : CGFloat = 0
    
    
    
    /// the list of all photos
    @State var imageList = [arPhotoCarousel]()
    
    
    /// show/not show the image detail sheet
    @State var showSheet = false
    //current image selected
    //@State var imageSelected = ArImage()
    
    
    /// current image selected index in the arPhoto array
    @State var selectedIndex = -1
    var body : some View{
        
        NavigationView{
            
            VStack{
                
                Spacer()
                
                HStack(spacing: 20){
                    //display all images in carousel list
                    ForEach(0..<imageList.count, id: \.self){i  in

                        //when a single image is tapped, show the detail sheet
                        CarouselItem(data: self.imageList[i]).onTapGesture {
                            //imageSender holds the info of tapped image ready to use.
                            photoTapped = self.imageList[i]
                            
                            self.showSheet = true
                           //when a single image is long pressed, show the alert asking whether user want to delete current image from core data or not
                        }.onLongPressGesture {
                            self.selectedIndex = i
                            self.showAlert = true
                        }.offset(x: self.carouselOffset)
                        //below are the calculations used to customize/mimic the behavior of the carousel list according to the UI constraints. As no carousel list is supported by SwiftUI, we have to do it manually.
                                .gesture(DragGesture()

                                    //when user is dragging the image, animate the process by changing the offset.
                                    .onChanged({ (value) in
                                        self.carouselOffset = (value.translation.width > 0 ? value.location.x : value.location.x - UIScreen.main.bounds.width)
                                       

                                    })
                                    //when user dragging finished and release their fingers.
                                    
                                    .onEnded({ (value) in

                                        if value.translation.width > 0{

                                            if (self.index == 0) {
                                                self.carouselOffset = 0
                                            }
                                            else {
                                                //determine whether the scrolling distance is enough to go back or forward
                                                if (value.translation.width > ((UIScreen.main.bounds.width / 2)-40)) {
                                                    self.index = index - 1
                                                    var tem = 0
                                                    //current image view has bigger height
                                                    while (tem < imageList.count){
                                                        
                                                        if (tem == self.index) {
                                                            imageList[tem].show = true
                                                            tem = tem+1
                                                        }
                                                        else {
                                                            imageList[tem].show = false
                                                            tem = tem+1
                                                        }
                                                    }
                                                   
                                    
                                                    
                                                }
                                                self.carouselOffset = -((UIScreen.main.bounds.width - 30 + 20) * CGFloat(self.index))
                                            }

                                        }
                                        else{
                                            if (self.index == imageList.count - 1) {
                                                self.carouselOffset = -((UIScreen.main.bounds.width-10) * (CGFloat(imageList.count) - 1))
                                            }
                                            else {
                                                //determine whether the scrolling distance is enough to go back or forward
                                                if (-(value.translation.width) > ((UIScreen.main.bounds.width / 2)-40)) {
                                                    
                                                    self.index = index + 1
                                                    var tem = 0
                                                    //current image view has bigger height
                                                    while (tem < imageList.count){
                                                        
                                                        if (tem == self.index) {
                                                            imageList[tem].show = true
                                                            tem = tem+1
                                                        }
                                                        else {
                                                            imageList[tem].show = false
                                                            tem = tem+1
                                                        }
                                                    }

                                                }
                                                print(self.index)
                                                self.carouselOffset = -((UIScreen.main.bounds.width - 30 + 20) * CGFloat(self.index))
                                               
                                            }


                                        }
                                    })
                                )

                    }.onDelete(perform: delete)
                }
                .frame(width: UIScreen.main.bounds.width)
                .offset(x: self.hStackOffset)
                Spacer()
            }
            //the detail sheet of a single image
            .sheet(isPresented: self.$showSheet) {
                NavigationView {
                    //if (self.imageSelected != nil) {
                        //show the image detail
                    CarouselDetail(aPhoto: photoTapped)
                //}
                }.navigationViewStyle(StackNavigationViewStyle())
                //show the delete image alert
            }.alert(isPresented: $showAlert, content: { self.deleteAlert })
            //animate the scroll behavior among images.
            .animation(.easeInOut)
           
            .background(Color.gray.opacity(0.1).edgesIgnoringSafeArea(.bottom))
            .navigationBarTitle("").navigationBarHidden(true)
           
            .onAppear {
                
                //on first appear, load all images from core data and append the image into the image list that will be displayed.
                var index = 0
                for aPhoto in self.photos {
                    let card = arPhotoCarousel(id: index, img: UIImage(data: aPhoto.photos!)!, dateCaptured: aPhoto.date!, show: false, lat: Double(truncating: aPhoto.lat!), long: Double(truncating: aPhoto.long!))
                    
                    self.imageList.append(card)
                    index = index + 1
                }
                //mark the first image item as selected (height is different)
                if self.imageList.count != 0 {
                    self.imageList[0].show = true
                }
                
                //The default position is in the middle. But we need to scroll the image list to the leftmost
                //first case: odd number of images, we just need to set the offset to be (screensize + HStack-spacing) *self.imageList.count/2
                //second case: even number of images, we just need to set the offset to be ((screensize + HStack-spacing) *self.imageList.count/2) - (screensize + HStack-spacing)/2
                
                if (self.imageList.count % 2 != 0) {
                    self.hStackOffset = ((UIScreen.main.bounds.width - 30 + 20) * CGFloat(self.imageList.count / 2))
                }
                if (self.imageList.count % 2 == 0) {
                    self.hStackOffset = ((UIScreen.main.bounds.width - 30 + 20) * CGFloat(self.imageList.count / 2)) - (UIScreen.main.bounds.width - 30 + 20)/2
                }
               
              
               
                
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    var deleteAlert: Alert {
        Alert(title: Text("Delete this photo?"),
              
              primaryButton:
                //if yes selected, remove the current long pressed image from both the list and coredata model.
                .default(Text("Yes")) {
                    let photoToDelete = self.photos[self.selectedIndex]
                    self.imageList.remove(at: self.selectedIndex)
                    self.hStackOffset = ((UIScreen.main.bounds.width - 30 + 20) * CGFloat(self.imageList.count / 2)) - (self.imageList.count % 2 == 0 ? ((UIScreen.main.bounds.width - 30 + 20) / 2) : 0)
                    self.index = 0
                    self.carouselOffset = 0
                    if self.imageList.count != 0 {
                    self.imageList[0].show = true
                    }

                // ❎ CoreData Delete operation
                self.managedObjectContext.delete(photoToDelete)
                
                // ❎ CoreData Save operation
                do {
                  try self.managedObjectContext.save()
                } catch {
                  print("Unable to delete selected note!")
                }
                    //If no selected, dismiss the alert and do nothing.
                }, secondaryButton:.default(Text("No")) {
                    self.showAlert = false
                }
              
              
        )
    }
    //delete a image at index "offset".
    func delete(at offsets: IndexSet) {
       
        let photoToDelete = self.photos[offsets.first!]
       
        // ❎ CoreData Delete operation
        self.managedObjectContext.delete(photoToDelete)
 
        // ❎ CoreData Save operation
        do {
          try self.managedObjectContext.save()
        } catch {
          print("Unable to delete selected note!")
        }
    }
    
}



