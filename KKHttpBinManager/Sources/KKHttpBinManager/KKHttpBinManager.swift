import Foundation
import UIKit

public enum ParserError: Error {
    case notADictionary
    case notAnImage
}

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

public protocol KKHttpBinManagerDelegate: class {
    func manager(_ manager: KKHttpBinManager, hasUpdatedProgress progess: Double)
    func managerDidComplete(_ manager: KKHttpBinManager)
    func manager(_ manager: KKHttpBinManager, didFailWithError error: Error)
}

public class KKHttpBinManager: NSObject {
    static let shared = KKHttpBinManager()
    private var queue = OperationQueue()
    var hasCompleted: Bool = false

    open weak var delegate: KKHttpBinManagerDelegate?

    typealias KKDictionaryCallback = (_ data: [String: Any]?, _ error: Error?) -> Void
    typealias KKImageCallback = (_ image: UIImage?, _ error: Error?) -> Void

    // MARK: Requests
    @discardableResult
    func getResponse(callback: @escaping KKDictionaryCallback) -> URLSessionTask {
        guard let url = URL(string: "http://httpbin.org/get") else {
            fatalError("URL doesn't available")
        }
        return requestDictionary(method: .get, url: url, callback: callback)
    }

    @discardableResult
    func postResponse(name: String, callback: @escaping KKDictionaryCallback) -> URLSessionTask {
        guard let url = URL(string: "http://httpbin.org/post") else {
            fatalError("URL doesn't available")
        }
        return requestDictionary(method: .post, url: url, body: "name=\(name)", callback: callback)
    }

    @discardableResult
    func fetchImage(callback: @escaping KKImageCallback) -> URLSessionTask {
        guard let url = URL(string: "http://httpbin.org/image/png") else {
            fatalError("URL doesn't available")
        }
        return requestImage(url: url, callback: callback)
    }

    // MARK: Operation
    open func executeOperation() {
        queue.cancelAllOperations()
        let operation = KKHttpBinManagerOperation()
        queue.addOperation(operation)

        operation.delegate = self
    }
}

extension KKHttpBinManager: KKHttpBinManagerOperationDelegate {
    func operationDidComplete(_ operation: KKHttpBinManagerOperation) {
        print("Operation did completed")
        delegate?.managerDidComplete(self)
    }

    func operation(_ operation: KKHttpBinManagerOperation, didFailWithError error: Error) {
        print("Operation did failed with error:", error)
        delegate?.manager(self, didFailWithError: error)
    }

    func operation(_ operation: KKHttpBinManagerOperation, hasUpdatedProgress progess: Double) {
        print("Operation did update progress:", progess)
        delegate?.manager(self, hasUpdatedProgress: progess)
    }
}

private extension KKHttpBinManager {

    func requestDictionary(method: HttpMethod, url: URL, body: String? = nil, callback: @escaping KKDictionaryCallback) -> URLSessionTask {
        return _request(method: method, body: body, url: url) { (data, error) in
            guard let responseData = data, error == nil else {
                callback(nil, error)
                return
            }

            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] else {
                    callback(nil, ParserError.notADictionary)
                    return
                }
                callback(jsonObject, nil)
            }
            catch {
                callback(nil, error)
            }
        }
    }

    func requestImage(url: URL, callback: @escaping KKImageCallback) -> URLSessionTask {
        return _request(method: .get, url: url) { (data, error) in
            guard
                let responseData = data,
                let image = UIImage(data: responseData),
                error == nil
            else {
                callback(nil, error)
                return
            }
            callback(image, nil)
        }
    }

    func _request(method: HttpMethod = .get, body: String? = nil, url: URL, callback: @escaping (Data?, Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let requestBody = body,
            let bodyData = requestBody.data(using: .ascii) {
            request.httpBody = bodyData
            request.setValue(String(bodyData.count), forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }

        let currentTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            callback(data, error)
        }

        currentTask.resume()
        return currentTask
    }
}
