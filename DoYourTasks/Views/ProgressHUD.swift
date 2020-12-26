//
//  ProgressHUD.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 25/12/2020.
//

import SwiftUI

struct ProgressHUD: View {
    let placeholder: String
    let style = StrokeStyle(lineWidth: 6, lineCap: .round)
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 28) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(AngularGradient(gradient: Gradient(colors: [.gray, Color.gray.opacity(0.5)]), center: .center), style: style)
                .frame(width: 80, height: 80)
                .rotationEffect(.init(degrees: animate ? 360 : 0))
                .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))

            Text(placeholder)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 35)
        .background(BlurView())
        .cornerRadius(15)
        .onAppear {
            animate.toggle()
        }
    }
}

struct ProgressHUD_Previews: PreviewProvider {
    static var previews: some View {
        ProgressHUD(placeholder: "Signing in")
            .previewLayout(.sizeThatFits)
    }
}
