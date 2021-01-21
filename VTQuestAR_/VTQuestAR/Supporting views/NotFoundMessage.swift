//
//  NotFoundMessage.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/23/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import SwiftUI

/// This class is used whenever the query of coredata model is invalid to indicate that no building found.
struct NotFoundMessage: View {
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .imageScale(.large)
                .font(Font.title.weight(.medium))
                .foregroundColor(.red)
                .padding()
            Text("No Building Found!\n\nPlease enter another search query to search for a building on VT main campus!")
                .fixedSize(horizontal: false, vertical: true)   // Allow lines to wrap around
                .multilineTextAlignment(.center)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .background(Color(red: 1.0, green: 1.0, blue: 240/255))     // Ivory color
    }
}

struct NotFoundMessage_Previews: PreviewProvider {
    static var previews: some View {
        NotFoundMessage()
    }
}
