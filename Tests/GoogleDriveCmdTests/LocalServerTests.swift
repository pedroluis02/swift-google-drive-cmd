import XCTest
import Foundation
import NIOHTTP1
@testable import gdrive_cli

final class LocalServerTests: XCTestCase {
    func testStartServer() throws {
        let host = "localhost"
        let port = 8080
        let server = HttpServer(host: host, port: port)
        
        let requestResult = expectation(description: "Request call result")
        var responseStatus: Int? = nil
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            let url = URL(string: server.localUrl)!
            URLSession.shared.dataTask(with: url) { (_, response, _) in
                if let httpResponse = response as? HTTPURLResponse {
                    responseStatus = httpResponse.statusCode
                }
                requestResult.fulfill()
            }.resume()
        }
        
        try startAndListenServerASync(with: server)
        
        wait(for: [requestResult], timeout: 10.0)
        XCTAssertNotNil(responseStatus)
    }
    
    private func startAndListenServerASync(with server: HttpServer) throws {
        try server.start() { server, request -> (String, HTTPResponseStatus) in
            return ("OK", .ok)
        }
    }
}
