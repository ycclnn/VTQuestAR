//
//  ShakeGuestureNotifier.swift
//  UIDemo
//
//  Created by zhennan on 2020/5/27.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import Combine

//This class is used in the tab view "Recognition". Whenver user's shake gesture get captured, the ML/AR mode will switch.(ML->AR / AR->ML)

//set up a notification publisher
extension NSNotification.Name {
    public static let deviceDidShakeNotification = NSNotification.Name("shakeNotification")
}

extension UIWindow {
    //when shake gesture detected, send out the notification to the subscribers(in ML.swift).
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        NotificationCenter.default.post(name: .deviceDidShakeNotification, object: event)
    }
}
