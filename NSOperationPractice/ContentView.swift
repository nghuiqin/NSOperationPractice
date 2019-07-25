//
//  ContentView.swift
//  NSOperationPractice
//
//  Created by Hui Qin Ng on 2019/7/25.
//  Copyright © 2019 Hui Qin Ng. All rights reserved.
//


import SwiftUI
import Combine
import KKHttpBinManager

final class ProgressData: BindableObject {
    let willChange = PassthroughSubject<Void, Never>()
    private let manager = KKHttpBinManager()

    var progress: Double = 0.0 {
        willSet {
            willChange.send()
        }
    }

    func execute() {
        manager.delegate = self
        manager.executeOperation()
    }
}

extension ProgressData: KKHttpBinManagerDelegate {
    func managerDidComplete(_ manager: KKHttpBinManager) {

    }

    func manager(_ manager: KKHttpBinManager, didFailWithError error: Error) {

    }

    func manager(_ manager: KKHttpBinManager, hasUpdatedProgress aProgess: Double) {
        DispatchQueue.main.async {
            self.progress = aProgess
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var progressData: ProgressData

    var body: some View {
        VStack {
            ProgressBar(progress: $progressData.progress)
            Button(
                action: {
                    self.progressData.execute()
                },
                label: {
                    Text("Execute")
                }
            )
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ProgressData())
    }
}
#endif
