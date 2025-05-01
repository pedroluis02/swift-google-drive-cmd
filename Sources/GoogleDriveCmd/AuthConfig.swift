import Foundation

struct AuthConfig: Codable {
    let clientId: String
    let clientSecret: String
    let authUri: String
    let authScope: String
    let tokenUri: String
    let redirectPath: String
}
