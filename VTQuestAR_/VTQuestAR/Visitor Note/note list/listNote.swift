//
//  listNote.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/8.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI

struct listNote: View {
    @Binding var hidden: Bool
    @Environment(\.managedObjectContext) var managedObjectContext
   
    // ❎ CoreData FetchRequest returning all Building entities in the database
    @FetchRequest(fetchRequest: Note.allNotessFetchRequest()) var notes: FetchedResults<Note>
    var body: some View {
        //NavigationView{
            List {

                ForEach(self.notes) { aNote in
                    NavigationLink(destination: listNoteDetails(note: aNote, image: self.getImage(imageData: aNote.photoAndAudio!.photo!))){
                        listNoteItem(note: aNote, image: self.getImage(imageData: aNote.photoAndAudio!.photo!))
                        
                    }
                }
                .onDelete(perform: delete)
                
                
            }.navigationBarTitle("Notes" ,displayMode: .inline)
            .navigationBarHidden(false)
           
    }
    
    func getImage(imageData: Data) -> UIImage {
        let imageReturned = UIImage(data: imageData)
        return imageReturned!
    }
    func delete(at offsets: IndexSet) {
       
        let noteToDelete = self.notes[offsets.first!]
       
        // ❎ CoreData Delete operation
        self.managedObjectContext.delete(noteToDelete)
 
        // ❎ CoreData Save operation
        do {
          try self.managedObjectContext.save()
        } catch {
          print("Unable to delete selected note!")
        }
    }
}


