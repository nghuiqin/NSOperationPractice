//
//  ProgressBar.swift
//  NSOperationPractice
//
//  Created by Hui Qin Ng on 2019/7/25.
//  Copyright © 2019 Hui Qin Ng. All rights reserved.
//
//  ProgressBar reference:
//  https://rscodesios.wordpress.com/2019/07/23/creating-a-progressbar-in-swiftui/

import SwiftUI

struct ProgressBar: View {
    @Binding var progress: Double

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(.gray)
                .opacity(0.3)
                .frame(width: 300, height: 8)
            Rectangle()
                .foregroundColor(.blue)
                .frame(width: 300 * CGFloat(progress), height: 8)
                .animation(.linear(duration: 0.6))
        }
        .cornerRadius(4)
    }
}

#if DEBUG
struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(progress: .constant(0.3))
    }
}
#endif
