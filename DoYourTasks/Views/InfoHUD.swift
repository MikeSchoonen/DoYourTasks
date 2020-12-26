//
//  InfoHUD.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 25/12/2020.
//

import SwiftUI

struct InfoHUD: View {
    var title: String
    var systemImage: String? = nil
    
    var body: some View {
        content
            .foregroundColor(.gray)
            .padding(.horizontal, 10)
            .padding(14)
            .background(
                BlurView()
                    .clipShape(Capsule())
                    .shadow(color: Color(.black).opacity(0.22), radius: 12, x: 0, y: 5)
            )
    }
    
    var content: some View {
        if let image = systemImage {
            return AnyView(Label(title, systemImage: image))
        } else {
            return AnyView(Text(title))
        }
    }
}

struct InfoHUD_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InfoHUD(title: "Saved image", systemImage: "photo")
            InfoHUD(title: "Saved")
        }.previewLayout(.sizeThatFits)
    }
}
