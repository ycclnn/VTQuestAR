//
//  arPhotoList.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/8.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI

/// The classic list style to display the photos taken
struct arPhotoList: View {
    
    /// core data context
    @Environment(\.managedObjectContext) var managedObjectContext
    
    /// Fetch request result containing all photo taken by the user
    @FetchRequest(fetchRequest: ArPhoto.allPhotosFetchRequest()) var photos: FetchedResults<ArPhoto>
    @Binding var hide: Bool
    var body: some View {
        List{
            ForEach(photos){aPhoto in
                
                
                //arPhotoDetail(aPhoto: aPhoto)
                NavigationLink(destination: arPhotoDetail(aPhoto: aPhoto, hide: self.$hide)){
                    arPhotoItem(aPhoto: aPhoto)

                }
//                .sheet(isPresented: self.$showSheet) {
                   // NavigationView {
//                        //if (self.imageSelected != nil) {
//                            //show the image detail
//                        CarouselDetail(aPhoto: photoTapped)
//                    //}
//                    }.navigationViewStyle(StackNavigationViewStyle())
//                    //show the delete image alert
//                }
                
               
            }.onDelete(perform: delete)
        }
        

    }
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
