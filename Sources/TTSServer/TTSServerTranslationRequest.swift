import Foundation
import Hummingbird

/// Request model for the translation endpoint
struct TTSServerTranslationRequest {
    let fileURL: URL
    let model: String
    let responseFormat: TTSServerTranslationFormat
    let prompt: String?
    let temperature: Double?

    /// Response format for translation
    enum ResponseFormat: String {
        case json
        case text
        case srt
        case verboseJson
        case vtt
    }
}

/// Response format for translation endpoint
enum TTSServerTranslationFormat: String {
    case json
    case text

    var contentType: String {
        switch self {
        case .json:
            return "application/json"
        case .text:
            return "text/plain"
        }
    }
}

/// Translation response model
struct TTSServerTranslationResponse: Encodable {
    let text: String
}
