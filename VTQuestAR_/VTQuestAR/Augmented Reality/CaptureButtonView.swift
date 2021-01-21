//
//  customCamera.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/10.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import UIKit
import SwiftUI
import AVFoundation

/// This view is the capture button that is used to take pictures.
struct CaptureButtonView: View {
    @State private var animationAmount: CGFloat = 1
    var body: some View {
        Image(systemName: "camera").font(.largeTitle)
            .padding(30)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Circle())
//            .overlay(
//                Circle()
//                    .stroke(Color.blue)
//                    .scaleEffect(animationAmount)
//                    .opacity(Double(2 - animationAmount))
//                    .animation(Animation.easeOut(duration: 1)
//                        .repeatForever(autoreverses: false))
//        )
            .onAppear
            {
                self.animationAmount = 2
        }
    }
}
