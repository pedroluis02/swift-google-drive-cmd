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
        return try await doRequest(self.createTokenRequestQueryItems())
    }
    
    func refreshToken(refreshToken value: String) async throws -> TokenResult {
        return try await doRequest(self.createTokenRefreshQueryItems(value))
    }
    
    private func doRequest(_ queryItems: [URLQueryItem]) async throws -> TokenResult {
        let baseURL = URL(string: config.accessTokenUrl)!
        
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue(self.createBasicAuth(), forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = self.createHttpBody(queryItems)
        
        let session = URLSession(configuration: .default)
        let (data, _) = try await session.data(for: request)
        
        return try data.toToken()
    }
    
    private func createBasicAuth() -> String {
        let token = "\(config.clientId):\(config.clientSecret)"
        let tokenBase64 = String(data: token.data(using: .utf8)!.base64EncodedData(), encoding: .utf8)!
        return "Basic \(tokenBase64)"
    }
    
    private func createTokenRequestQueryItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code.code!),
            URLQueryItem(name: "redirect_uri", value: code.endpoint)
        ]
    }
    
    private func createTokenRefreshQueryItems(_ refreshToken: String) -> [URLQueryItem] {
        return [
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "client_secret", value: config.clientSecret),
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
        ]
    }
    
    private func createHttpBody(_ queryItems: [URLQueryItem]) -> Data? {
        var bodyComponents = URLComponents(string: "")!
        bodyComponents.queryItems = queryItems
        let queryString = bodyComponents.url!.query!
        return queryString.data(using: .utf8)
    }
}

private extension Data {
    func toToken() throws -> TokenResult {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(TokenResult.self, from: self)
    }
}
