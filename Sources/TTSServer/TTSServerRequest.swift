import Foundation

/// Request model conforming to OpenAI Speech API specification
struct TTSServerRequest: Decodable {
    /// The text to generate audio for. Maximum length of 4096 characters.
    let input: String

    /// One of the available TTS models: tts-1 or tts-1-hd
    let model: String

    /// The voice to use for the text-to-speech
    let voice: String?

    /// The format to audio in. Supported formats are mp3, opus, aac, flac, wav, and pcm.
    /// Default: mp3
    let responseFormat: TTSServerAudioFormat?

    /// Coding keys for custom mapping
    enum CodingKeys: String, CodingKey {
        case input
        case model
        case voice
        case responseFormat = "response_format"
    }

    /// Validates the request
    func validate() throws {
        // Check input is not empty
        guard !input.isEmpty else {
            throw TTSServerError.invalidInput("Input text cannot be empty")
        }

        // Check input length (OpenAI has a 4096 character limit)
        guard input.count <= 4096 else {
            throw TTSServerError.invalidInput("Input text exceeds maximum length of 4096 characters")
        }

        // Check model is tts-1 (we just validate, it doesn't affect behavior)
        guard model == "tts-1" else {
            throw TTSServerError.invalidModel(model)
        }
    }
}
