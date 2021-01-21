//
//  NavigationStyle.swift
//  Pods
//
//  Created by zhennan on 2020/7/16.
//

import SwiftUI

extension View {
    
    public func customNavigationViewStyle() -> some View {

        if UIDevice.current.userInterfaceIdiom == .phone {
            // Use single column navigation view for iPhone
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            // Use double column navigation view for iPad
            return AnyView(self
                .navigationViewStyle(DoubleColumnNavigationViewStyle())
                            .padding(1)  // Workaround to show master view until Apple fixes the bug
            )
        }
    }
    
}
