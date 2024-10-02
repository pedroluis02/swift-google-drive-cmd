import Foundation
import ArgumentParser

@main
struct GoogleDriveCmd: AsyncParsableCommand {
    @Argument
    var command = ""

    mutating func run() async throws {
        print("Google Drive Cmd Client")
        print("command: \(command)")
        
        let config = try loadConfig()
        print(config)
        
        try await self.startAuth(config)
    }
    
    private func loadConfig() throws -> AuthConfig {
        let dir = FileManager.default.currentDirectoryPath
        let fileName = "google.json"
        let path = "\(dir)/\(fileName)"
        let json = try String(contentsOfFile: path, encoding: .utf8)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(AuthConfig.self, from: json.data(using: .utf8)!)
    }
    
    private func startAuth(_ config: AuthConfig) async throws {
        let captor = BrowserAccountCaptor(config: config)
        let result = try await captor.startSigningInPageSync()
        print("code: \(result)")
        
        let tokenService = AuthTokenService(config: config, code: result)
        let token = try await tokenService.requestToken()
        print("token: \(token)")
    }
}
