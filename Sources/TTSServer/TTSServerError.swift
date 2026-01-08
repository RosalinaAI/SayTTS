import Foundation
import Hummingbird

enum TTSServerError: LocalizedError {
    case invalidModel(String)
    case invalidVoice(String)
    case invalidInput(String)
    case formatNotSupported(String)
    case conversionFailed(String)
    case sayCommandFailed(Int32)
    case processFailed(Error)
    case fileReadFailed(String)
    case fileWriteFailed(String)
    case recognitionFailed(String)
    case invalidFile(String)
    case missingFile
    case missingModel

    var errorDescription: String? {
        switch self {
        case .invalidModel(let model):
            return "Invalid model: \(model). Supported model is 'tts-1'."
        case .invalidVoice(let voice):
            return "Invalid voice: \(voice)."
        case .invalidInput(let reason):
            return "Invalid input: \(reason)."
        case .formatNotSupported(let format):
            return "Format not supported: \(format)."
        case .conversionFailed(let reason):
            return "Audio conversion failed: \(reason)."
        case .sayCommandFailed(let status):
            return "Say command failed with exit code: \(status)."
        case .processFailed(let error):
            return "Process execution failed: \(error.localizedDescription)."
        case .fileReadFailed(let path):
            return "Failed to read file: \(path)."
        case .fileWriteFailed(let path):
            return "Failed to write file: \(path)."
        case .recognitionFailed(let reason):
            return "Speech recognition failed: \(reason)."
        case .invalidFile(let reason):
            return "Invalid file: \(reason)."
        case .missingFile:
            return "Missing required file parameter."
        case .missingModel:
            return "Missing required model parameter."
        }
    }

    /// Converts this error to an HTTP response
    var asResponse: Response {
        let errorMessage = self.errorDescription ?? "Unknown error"

        // Determine status code based on error type
        let status: HTTPResponse.Status
        switch self {
        case .invalidModel, .invalidVoice, .invalidInput, .formatNotSupported, .missingFile, .missingModel, .invalidFile:
            status = .badRequest  // 400 - client error
        case .conversionFailed, .sayCommandFailed, .processFailed, .fileReadFailed, .fileWriteFailed, .recognitionFailed:
            status = .internalServerError  // 500 - server error
        }

        var response = Response(status: status)
        response.headers[.contentType] = "text/plain"
        response.body = .init(byteBuffer: .init(string: errorMessage))
        return response
    }
}
