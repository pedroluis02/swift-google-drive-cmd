import Foundation

struct TokenResult: Codable, Equatable {
    let accessToken: String
    let expiresIn: Int
    let idToken: String
    let scope: String
    let tokenType: String
    let refreshToken: String
}
