//
//  listNodeItem.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/1.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI

//each note item in list view
struct listNoteItem: View {
    let note: Note
    //let image: UIImage
    let image: UIImage
    
    var body: some View {
        HStack {
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100.0)
            
            
            
            
            VStack(alignment: .leading) {
                Text(note.noteTitle ?? "")
                Text(note.dateVisited ?? "")
                
            }
            .font(.system(size: 14))
            
        }
        
    }
    
}

