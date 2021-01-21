//
//  arPhotoItem.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/8.
//  Copyright © 2020 zhennan yao. All rights reserved.
//09

import SwiftUI

/// The single photo item in a list, displaying photo thumbnail, capture date, and capture lat/long.
struct arPhotoItem: View {
    //the ArPhoto object
    let aPhoto: ArPhoto
    var body: some View {
        HStack {
            //the thumbnail
            Image(uiImage: UIImage(data:aPhoto.photos!)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100.0, height: 100)
                
            //the date and location when the photo was captured
            VStack(alignment: .leading) {
                Text(aPhoto.date ?? "")
                Text("(\(Double(truncating: aPhoto.lat!), specifier: "%.6f"),\(Double(truncating: aPhoto.long!), specifier: "%.6f"))")
               
            }
            .font(.system(size: 14))
            
        }
    }
}

