import Foundation

/// Generates speech using macOS say command
struct TTSServerGenerator {

    /// Generates audio from text using the say command
    /// - Parameters:
    ///   - text: The text to synthesize
    ///   - voice: Optional voice name (default system voice if nil)
    /// - Returns: URL to the generated AIFF file
    func generate(text: String, voice: String? = nil) async throws -> URL {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".aiff")

        return try await withCheckedThrowingContinuation { cont in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/say")

            var arguments: [String] = []
            if let voice = voice, voice != "default" {
                arguments += ["-v", voice]
            }
            arguments += ["-o", outputURL.path]
            arguments += [text]
            process.arguments = arguments

            process.terminationHandler = { proc in
                if proc.terminationStatus == 0 {
                    cont.resume(returning: outputURL)
                } else {
                    cont.resume(throwing: TTSServerError.sayCommandFailed(proc.terminationStatus))
                }
            }

            do {
                try process.run()
            } catch {
                cont.resume(throwing: TTSServerError.processFailed(error))
            }
        }
    }
}
