//
//  UserData.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/23/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import Combine
import SwiftUI
import SpriteKit
import ARKit
import Vision

final class UserData: ObservableObject {
 
    static var shared = UserData()
   
    
    
    
    
    // ❎ Subscribe to notification that the managedObjectContext completed a save
    @Published var savedInDatabase =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    
    //*** Due to iOS 14 or Swift bug, the following approach for moving keyboard up does
    //    not work, Therefore, I temporarily comment out this section. Will change it back
    //    when the bug is fixed.
    
//    // Publish currently shown keyboard height
//    @Published var currentKeyboardHeight: CGFloat = 0
//    /*
//    
//     A NotificationCenter object (or simply, notification center) provides a notification
//     dispatch mechanism that enables the broadcast of information to registered observers.
//     */
// 
//    // Declare an object reference to the default notification center
//    private var notificationCenter: NotificationCenter
// 
//    // Initialize the default Notification Center
//    init(center: NotificationCenter = .default) {
//        //
//        
//        notificationCenter = center
//        /*
//         Add self as an Observer for the "Keyboard Will Show" notification by specifying
//         the name of the method to invoke upon that notification.
//         */
//        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//       
//        /*
//        Add self as an Observer for the "Keyboard Will Hide" notification by specifying
//        the name of the method to invoke upon that notification.
//        */
//        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
// 
//    // Remove self as an Observer from the Notification Center notifications
//    deinit {
//        notificationCenter.removeObserver(self)
//    }
// 
//    // This function is called upon the "Keyboard Will Show" notification
//    @objc func keyBoardWillShow(notification: Notification) {
//        // Obtain the height of the keyboard to be shown
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            currentKeyboardHeight = keyboardSize.height
//        }
//    }
// 
//    // This function is called upon the "Keyboard Will Hide" notification
//    @objc func keyBoardWillHide(notification: Notification) {
//        currentKeyboardHeight = 0
//    }
// 
}
