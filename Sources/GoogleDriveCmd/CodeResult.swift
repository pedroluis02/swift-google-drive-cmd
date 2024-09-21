import Foundation

struct CodeResult {
    let endpoint: String
    let code: String?
    
    init(endpoint: String, code: String?) {
        self.endpoint = endpoint
        self.code = code
    }
}
