import Foundation

struct AccountCode {
    var code: String?
    var state: String?
    var error: String?
    
    init(code: String? = nil, state: String? = nil, error: String? = nil) {
        self.code = code
        self.state = state
        self.error = error
    }
    
    init(from components: URLComponents) {
        for queryItem in components.queryItems! {
          if let value = queryItem.value {
            switch queryItem.name {
            case "code":
              code = value
            case "state":
              state = value
            case "error":
              error = value
            default:
              break
            }
          }
        }
    }
}
