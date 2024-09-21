import Foundation
import Dispatch
import NIOHTTP1

class BrowserAccountCaptor {
    private let config: AuthConfig
    private var code: AccountCode?
    
    init(config: AuthConfig) {
        self.config = config
    }
    
    func startSigningInPageSync() async throws -> (String, AccountCode?) {
        return await withCheckedContinuation { continuation in
            try! startSigningInPage() { endpoint, code in
                continuation.resume(returning: (endpoint, code))
            }
        }
    }
    
    func startSigningInPage(completion: @escaping (String, AccountCode?) -> Void) throws {
        let semaphore = DispatchSemaphore(value: 0)
        let serverUrl = try startServer(semaphore: semaphore)
        
        let serverEndpoint = serverUrl + config.redirectPath;
        let signInPageURL = createSignInPageURL(serverEndpoint)
        openURL(signInPageURL)
        
        _  = semaphore.wait(timeout: .distantFuture)
        completion(serverEndpoint, self.code)
    }
    
    private func startServer(semaphore: DispatchSemaphore) throws -> String {
        let server = HttpServer()
        try server.start() { (server, request) -> (String, HTTPResponseStatus) in
            if request.uri.unicodeScalars.starts(with: self.config.redirectPath.unicodeScalars) {
                if let components = URLComponents(string: request.uri) {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        semaphore.signal()
                    }
                    self.code = AccountCode(from: components)
                    return ("code received.", .ok)
                } else {
                    return ("failed to get code.", .ok)
                }
            } else {
                return ("not found.", .notFound)
            }
        }
        
        return server.localUrl
    }
    
    private func createSignInPageURL(_ redirectUri: String) -> URL {
        var components = URLComponents(string: config.authorizeUrl)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "email"),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "show_dialog", value: "false")
        ]
        return components.url!
    }
}
