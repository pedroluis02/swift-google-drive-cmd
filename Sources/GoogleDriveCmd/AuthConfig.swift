import Foundation

struct AuthConfig: Codable {
    let clientId: String
    let clientSecret: String
    let authorizeUrl: String
    let accessTokenUrl: String
    let redirectPath: String
}
