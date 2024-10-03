import Foundation
import NIOHTTP1

class AuthTokenService {
    private let config: AuthConfig
    private let code: CodeResult
    
    init(config: AuthConfig, code: CodeResult) {
        self.config = config
        self.code = code
    }
    
    func requestToken() async throws -> TokenResult {
        let baseURL = URL(string: config.accessTokenUrl)!
        
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        //request.setValue(self.createBasicAuth(), forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = self.createHttpBody()
        
        let session = URLSession(configuration: .default)
        let (data, _) = try await session.data(for: request)
        
        return try data.toToken()
    }
    
    private func createBasicAuth() -> String {
        let token = "\(config.clientId):\(config.clientSecret)"
        let tokenBase64 = String(data: token.data(using: .utf8)!.base64EncodedData(), encoding: .utf8)!
        return "Basic \(tokenBase64)"
    }
    
    private func createHttpBody() -> Data? {
        let queryItems = createQueryItems()
        
        var bodyComponents = URLComponents(string: "")!
        bodyComponents.queryItems = queryItems
        let queryString = bodyComponents.url!.query!
        return queryString.data(using: .utf8)
    }
    
    private func createQueryItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code.code!),
            URLQueryItem(name: "redirect_uri", value: code.endpoint)
        ]
    }
}

private extension Data {
    func toToken() throws -> TokenResult {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(TokenResult.self, from: self)
    }
}
