//
//  halfModal.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/11.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI

fileprivate enum Constants {
    //corner radius of the custom bottom sheet
    static let radius: CGFloat = 16
    //height of top ui element to indicate the close button
    static let indicatorHeight: CGFloat = 6
    //width of top ui element to indicate the close button
    static let indicatorWidth: CGFloat = 60
}


struct BottomSheetView<Content: View>: View {
    
    /// hide/show the sheet
    @Binding var isOpen: Bool
    
    
    /// the height when sheet is open
    let maxHeight: CGFloat
    
    /// the height when sheet is closed
    let minHeight: CGFloat
    
    /// content of sheet
    let content: () -> Content

    
    /// This will be the offset of dragging sheet view up and down
    @GestureState private var translation: CGFloat = 0

    //if open, the offset will be zero (maxHeight - maxHeight), if closed, it will be maxHeight - minHeight.
    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }
    
    /// The indicator that user can tap to close the sheet view
    private var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(
                width: Constants.indicatorWidth,
                height: Constants.indicatorHeight
        ).onTapGesture {
            //close upon tap
            self.isOpen.toggle()
        }
    }
    //initialize the sheet view
    init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.minHeight = 0
        self.maxHeight = maxHeight
        self.content = content
        self._isOpen = isOpen
    }

    var body: some View {
        GeometryReader { geometry in
            //two element: indicator and content
            VStack(spacing: 0) {
                self.indicator.padding()
                self.content()
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color.white)
            .cornerRadius(Constants.radius)
            .frame(height: geometry.size.height, alignment:  .bottom)
            .offset(y: max(self.translation + self.offset, 0))
            .animation(.interactiveSpring())
            .gesture(
                //The value parameter is the current data for the drag – where it started, how far it’s moved, where it’s predicted to end, and so on.
                //The state parameter is an inout value that is our property. So, rather than reading or writing dragAmount directly, inside this closure we should modify state.
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = self.maxHeight * 0.25
                    //if drag amount (in float) is larger than the snap distance, the sheet will be automatically closed by isOpen toggler.
                    if (value.translation.height > snapDistance) {
                        self.isOpen.toggle()
                    }
                    //if smaller than the snap distance, the sheet view will bounce back to it's maximum height
                    else {
                        return
                    }
                   
                }
            )
        }
    }
}
