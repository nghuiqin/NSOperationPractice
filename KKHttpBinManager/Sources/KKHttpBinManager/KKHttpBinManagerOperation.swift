//
//  File.swift
//  
//
//  Created by Hui Qin Ng on 2019/7/24.
//

import Foundation

protocol KKHttpBinManagerOperationDelegate : class {
    func operation(_ operation: KKHttpBinManagerOperation, hasUpdatedProgress progess: Double)
    func operationDidComplete(_ operation: KKHttpBinManagerOperation)
    func operation(_ operation: KKHttpBinManagerOperation, didFailWithError error: Error)
}

class KKHttpBinManagerOperation: Operation {

    weak var delegate: KKHttpBinManagerOperationDelegate?

    private var tasks: [URLSessionTask] = []
    private var port: Port? = nil
    private var isRunloopRunning = false

    override func main() {
        autoreleasepool {
            let getTask = KKHttpBinManager.shared.getResponse { [weak self] (dictionary, error) in
                guard let self = self else { return }
                self.quitRunloop()
                if error != nil {
                    self.cancel()
                    self.delegate?.operation(self, didFailWithError: error!)
                    return
                }
                self.delegate?.operation(self, hasUpdatedProgress: 0.33)
            }

            tasks.append(getTask)
            self.doRunloop()

            let postTask = KKHttpBinManager.shared.postResponse(name: "NG") { [weak self] (dictionary, error) in
                guard let self = self else { return }
                self.quitRunloop()
                if error != nil {
                    self.cancel()
                    self.delegate?.operation(self, didFailWithError: error!)
                    return
                }
                self.delegate?.operation(self, hasUpdatedProgress: 0.66)
            }

            tasks.append(postTask)
            self.doRunloop()

            let fetchImage = KKHttpBinManager.shared.fetchImage { [weak self] (image, error) in
                guard let self = self else { return }
                self.quitRunloop()
                if error != nil {
                    self.cancel()
                    self.delegate?.operation(self, didFailWithError: error!)
                }
                self.delegate?.operation(self, hasUpdatedProgress: 1)
                self.delegate?.operationDidComplete(self)
            }

            tasks.append(fetchImage)
            self.doRunloop()
        }
    }

    override func cancel() {
        super.cancel()
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }

    private func doRunloop() {
        isRunloopRunning = true
        port = Port()
        RunLoop.current.add(port!, forMode: .common)
        while isRunloopRunning && !isCancelled {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        }
        port = nil
    }

    private func quitRunloop() {
        port?.invalidate()
        isRunloopRunning = false
    }
}
