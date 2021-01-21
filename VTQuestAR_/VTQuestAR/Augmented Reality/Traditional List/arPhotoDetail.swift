//
//  arPhotoDetail.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/8.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI

/// The detail page of a single ArPhoto
struct arPhotoDetail: View {
    //the photo item
    let aPhoto: ArPhoto
 
    /// presentation mode for dismiss from current view
    @Environment(\.presentationMode) var presentationMode
    
    /// show the share sheet when user taps share button.
    @State var showShareSheet = false
    
    /// decide whether or not the nav bar is hidden
    @Binding var hide: Bool
    var body: some View {
//        ZStack {
        Form {
            Section(header: Text("Date captured")) {
                Text(aPhoto.date ?? "")
            }
            Section(header: Text("Note Photo")) {
                HStack {
                Spacer()
                Image(uiImage: UIImage(data: aPhoto.photos!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 300, maxWidth: 500, alignment: .center)
                Spacer()
                }
            }
            Section(header: Text("Location captured")) {
                Text("(\(aPhoto.lat!),\(aPhoto.long!))")
            }
            Section(header: Text("Location on map")) {
                HStack {
                    Spacer()
                    MapView(mapType: .standard, latitude: Double(truncating: aPhoto.lat!), longitude: Double(truncating: aPhoto.long!), delta: 1000,deltaUnit: "meters", annotationTitle: "Photo Location", annotationSubtitle: "\(aPhoto.lat!), \(aPhoto.long!)").frame(width: UIScreen.main.bounds.width - 100, height: 300)

                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {

            shareSheet(activityItems: [UIImage(data:self.aPhoto.photos!)!])
        }

        .font(.system(size: 14))
        .navigationBarTitle("Photo Detail", displayMode: .inline)
        .navigationBarHidden(self.hide)
        .navigationBarBackButtonHidden(false)
        .navigationBarItems(trailing: Button(action: {
            self.showShareSheet = true
            //self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Share")
        })

        
        
        .onAppear() {
            self.hide = false

        }
       
        //iPad, iPhone scenarios
        //.customNavigationViewStyle()
        
        
    }
}

