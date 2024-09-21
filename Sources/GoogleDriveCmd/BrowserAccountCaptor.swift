import Foundation
import Dispatch
import NIOHTTP1

class BrowserAccountCaptor {
    private let config: AuthConfig
    private var code: String?
    
    init(config: AuthConfig) {
        self.config = config
    }
    
    func startSigningInPageSync() async throws -> (CodeResult) {
        return await withCheckedContinuation { continuation in
            try! startSigningInPage() { continuation.resume(returning: $0) }
        }
    }
    
    func startSigningInPage(completion: @escaping (CodeResult) -> Void) throws {
        let semaphore = DispatchSemaphore(value: 0)
        let serverUrl = try startServer(semaphore: semaphore)
        
        let serverEndpoint = serverUrl + config.redirectPath;
        let signInPageURL = createSignInPageURL(serverEndpoint)
        openURL(signInPageURL)
        
        _  = semaphore.wait(timeout: .distantFuture)
        
        completion(CodeResult(endpoint: serverEndpoint, code: code))
    }
    
    private func startServer(semaphore: DispatchSemaphore) throws -> String {
        let server = HttpServer()
        try server.start() { (server, request) -> (String, HTTPResponseStatus) in
            if request.uri.unicodeScalars.starts(with: self.config.redirectPath.unicodeScalars) {
                if let components = URLComponents(string: request.uri) {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        semaphore.signal()
                    }
                    self.code = components.extractCode()
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

private extension URLComponents {
    func extractCode() -> String? {
        return queryItems?.first(where: { $0.name == "code" })?.value
    }
}
