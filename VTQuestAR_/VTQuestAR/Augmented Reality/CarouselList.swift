//
//  CarouselList.swift
//  VTQuestAR
//
//  Created by zhennan on 2020/7/21.
//

import SwiftUI

struct CarouselItem : View {
    
    var data : arPhotoCarousel
    
    var body : some View{
        
        VStack(alignment: .leading, spacing: 0){
           
                Image(uiImage: data.img!)
                    .resizable()

            Text(data.name!)
                .fontWeight(.bold)
                .padding(.vertical, 13)
                .padding(.leading)
            
        }
        .frame(width: UIScreen.main.bounds.width - 30, height: data.show! ? 500 : 440)
        .background(Color.white)
        .cornerRadius(25)
    }
}
