import Foundation
import Hummingbird

@main
struct TTSServerApp {
    static func main() async throws {
        let router = Router()
        let generator = TTSServerGenerator()
        let converter = TTSServerAudioConverter()

        // OpenAI Speech API compatible endpoint
        // POST /v1/audio/speech
        router.post("/v1/audio/speech") { request, context -> Response in
            do {
                // Decode the request
                let ttsRequest = try await request.decode(as: TTSServerRequest.self, context: context)

                // Validate the request
                try ttsRequest.validate()

                // Get the output format (default to mp3, but will error if not supported)
                let format = ttsRequest.responseFormat ?? .mp3

                // Check if format is supported
                guard format.isSupported else {
                    throw TTSServerError.formatNotSupported(format.rawValue)
                }

                // Generate AIFF audio using say command
                let aiffURL = try await generator.generate(
                    text: ttsRequest.input,
                    voice: ttsRequest.voice
                )

                // Convert to requested format if needed
                let finalURL: URL
                if format == .aiff {
                    finalURL = aiffURL
                } else {
                    finalURL = try await converter.convert(inputURL: aiffURL, to: format)
                    // Clean up original AIFF file
                    try? FileManager.default.removeItem(at: aiffURL)
                }

                // Read the audio data
                let audioData = try Data(contentsOf: finalURL)

                // Clean up final file
                try? FileManager.default.removeItem(at: finalURL)

                // Build response
                var response = Response(status: .ok)
                response.headers[.contentType] = format.contentType
                response.headers[.contentDisposition] = "attachment; filename=speech.\(format.fileExtension)"
                response.body = .init(byteBuffer: .init(data: audioData))
                return response
            } catch let error as TTSServerError {
                return error.asResponse
            } catch {
                return TTSServerError.processFailed(error).asResponse
            }
        }

        // Get configuration
        let config = TTSServerConfiguration.shared

        // Start the server
        let app = Application(
            router: router,
            configuration: .init(
                address: .hostname(config.host, port: config.port),
                serverName: "TTSServer"
            )
        )

        try await app.runService()
    }
}
