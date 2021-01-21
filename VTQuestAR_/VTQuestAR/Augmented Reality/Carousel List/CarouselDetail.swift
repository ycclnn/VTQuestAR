//
//  CarouselDetail.swift
//  VTQuestAR
//
//  Created by zhennan on 2020/7/21.
//

import SwiftUI


/// the detail view of each carousel image item
struct CarouselDetail : View {
    
    /// A arPhoto object
    let aPhoto: arPhotoCarousel
    
    /// Dismiss current view
    @Environment(\.presentationMode) var presentationMode
    
    /// control presentation of the share sheet
    @State var showShareSheet = false
    var body : some View{
        Form {
            Section(header: Text("Date captured")) {
                Text(aPhoto.dateCaptured ?? "")
                
            }
            Section(header: Text("Note Photo")) {
                HStack {
                    Spacer()
                    Image(uiImage: aPhoto.img!)
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
                MapView(mapType: .standard, latitude: aPhoto.lat!, longitude: aPhoto.long!, delta: 1000, deltaUnit: "meters", annotationTitle: "Photo Location", annotationSubtitle: "\(aPhoto.lat!), \(aPhoto.long!)").frame(width: UIScreen.main.bounds.width - 100, height: 300)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            shareSheet(activityItems: [self.aPhoto.img!])
        }
        .font(.system(size: 14))
        .navigationBarTitle("Photo Detail", displayMode: .inline)
        .navigationBarHidden(false)
  
        .navigationBarItems(leading: HStack{
                                Button("Back") {
                                    //dimiss from current view
                                    self.presentationMode.wrappedValue.dismiss()
                                }}
                            , trailing: Button(action: {
                                //show share page if button gets tapped
                                self.showShareSheet = true
                            }) {
                                Text("Share")
                            })
        
    }
}
