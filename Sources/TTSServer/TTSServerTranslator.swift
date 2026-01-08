import Foundation
import Speech

/// Handles speech recognition using Apple's Speech API
struct TTSServerTranslator {

    /// Recognizes speech from an audio file URL
    /// - Parameters:
    ///   - url: The URL of the audio file to transcribe
    ///   - locale: The locale identifier for the speech recognizer (e.g., "ru-RU", "en-US")
    /// - Returns: The transcribed text
    /// - Throws: TTSServerError if recognition fails
    func recognizeFile(url: URL, locale: String) async throws -> String {
        // Create a speech recognizer for the specified locale
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: locale)) else {
            throw TTSServerError.recognitionFailed("Unsupported locale: \(locale)")
        }

        // Check if recognizer is available
        guard recognizer.isAvailable else {
            throw TTSServerError.recognitionFailed("Speech recognizer is not available")
        }

        // Create recognition request
        let request = SFSpeechURLRecognitionRequest(url: url)

        // Perform recognition and wait for result
        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: TTSServerError.recognitionFailed(error.localizedDescription))
                    return
                }

                guard let result = result else {
                    continuation.resume(throwing: TTSServerError.recognitionFailed("No recognition result"))
                    return
                }

                // Return when we have a final result
                if result.isFinal {
                    let transcription = result.bestTranscription.formattedString
                    continuation.resume(returning: transcription)
                }
            }
        }
    }
}
