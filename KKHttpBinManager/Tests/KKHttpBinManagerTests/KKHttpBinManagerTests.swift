import XCTest
@testable import KKHttpBinManager

final class KKHttpBinManagerTests: XCTestCase {
    let manager = KKHttpBinManager()

    func testGetResponse() {
        let expect = expectation(description: "Expect a response")
        manager.getResponse { (response, error) in
            guard
                let response = response,
                let url = response["url"] as? String
            else { return }
            XCTAssert(url == "https://httpbin.org/get", "Response url doesn't match")
            expect.fulfill()
        }

        wait(for: [expect], timeout: 5)
    }

    func testPostResponse() {
        let input = "NG"
        let expect = expectation(description: "Expect a post response")
        manager.postResponse(name: input) { (response, error) in
            guard
                let response = response,
                let url = response["url"] as? String,
                let form = response["form"] as? [String: Any],
                let value = form["name"] as? String
            else { return }
            XCTAssert(url == "https://httpbin.org/post", "Response url doesn't match")
            XCTAssert(value == input, "Response data doesn't match")
            expect.fulfill()
        }

        wait(for: [expect], timeout: 5)
    }

    func testImage() {
        let expect = expectation(description: "Expect an image")
        manager.fetchImage { image, error in
            XCTAssert(image != nil, "Should return an UIImage object")
            expect.fulfill()
        }

        wait(for: [expect], timeout: 5)
    }

    func testOperation() {
        let expect = expectation(description: "Wait for operation")
        manager.executeOperation()
    }

    static var allTests = [
        ("testGetResponse", testGetResponse),
        ("testPostResponse", testPostResponse),
        ("testImage", testImage),
        ("testOperation", testOperation),
    ]
}
