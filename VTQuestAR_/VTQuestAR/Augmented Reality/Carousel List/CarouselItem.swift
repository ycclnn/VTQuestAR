//
//  CarouselList.swift
//  VTQuestAR
//
//  Created by zhennan on 2020/7/21.
//

import SwiftUI

/// the single item/photo in carousel list
struct CarouselItem : View {
    
    /// the arPhoto data
    var data : arPhotoCarousel
    
    var body : some View{
        
        VStack{
            
            Image(uiImage: data.img!)
                .resizable()
            
            HStack {
                Spacer()
                Text(data.dateCaptured!)
                    .fontWeight(.bold)
                    .padding(.bottom)
                Spacer()
            }
            
        }
        .background(Color.white)
        .frame(width: UIScreen.main.bounds.width - 30, height: data.show! ? 490 : 400)

//        .cornerRadius(25)
    }
}
