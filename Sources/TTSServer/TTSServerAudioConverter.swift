import Foundation

/// Handles audio format conversion using afconvert tool
struct TTSServerAudioConverter {

    /// Converts an AIFF file to the target format
    /// - Parameters:
    ///   - inputURL: The source AIFF file URL
    ///   - format: The target format
    /// - Returns: URL to the converted file
    func convert(inputURL: URL, to format: TTSServerAudioFormat) async throws -> URL {
        // Check if format is supported
        guard format.isSupported else {
            throw TTSServerError.formatNotSupported(format.rawValue)
        }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".\(format.fileExtension)")

        // For AIFF, just return the input (no conversion needed)
        if format == .aiff {
            return inputURL
        }

        // For MP3 or Opus, use ffmpeg
        if format == .mp3 || format == .opus {
            return try await runFFmpegConvert(inputURL: inputURL, outputURL: outputURL, format: format)
        }

        // For PCM, we need special handling
        if format == .pcm {
            return try await convertToPCM(inputURL: inputURL, outputURL: outputURL)
        }

        // Use afconvert for other formats
        return try await runAfconvert(inputURL: inputURL, outputURL: outputURL, format: format)
    }

    /// Runs afconvert to convert audio
    private func runAfconvert(inputURL: URL, outputURL: URL, format: TTSServerAudioFormat) async throws -> URL {
        try await withCheckedThrowingContinuation { cont in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/afconvert")

            var arguments = [inputURL.path, "-o", outputURL.path]
            arguments.append(contentsOf: format.afconvertArguments)
            process.arguments = arguments

            process.terminationHandler = { proc in
                if proc.terminationStatus == 0 {
                    cont.resume(returning: outputURL)
                } else {
                    cont.resume(throwing: TTSServerError.conversionFailed(
                        "afconvert exited with code \(proc.terminationStatus)"
                    ))
                }
            }

            do {
                try process.run()
            } catch {
                cont.resume(throwing: TTSServerError.processFailed(error))
            }
        }
    }

    /// Converts to PCM format by extracting raw samples from WAV
    /// PCM is raw 24kHz 16-bit signed little-endian data without header
    private func convertToPCM(inputURL: URL, outputURL: URL) async throws -> URL {
        // First convert to WAV format (24kHz mono 16-bit little-endian)
        let wavURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".wav")

        _ = try await runAfconvert(inputURL: inputURL, outputURL: wavURL, format: .wav)

        // Read the WAV file and skip the header to get raw PCM data
        let wavData = try Data(contentsOf: wavURL)
        // WAV header is 44 bytes, skip it to get raw PCM
        let pcmData = wavData.subdata(in: 44..<wavData.count)

        // Write raw PCM data
        try pcmData.write(to: outputURL)

        // Clean up temporary WAV file
        try? FileManager.default.removeItem(at: wavURL)

        return outputURL
    }

    /// Runs ffmpeg to convert audio to MP3 or Opus format
    /// - Parameters:
    ///   - inputURL: The source AIFF file URL
    ///   - outputURL: The destination file URL
    ///   - format: The target format (mp3 or opus)
    /// - Returns: URL to the converted file
    func runFFmpegConvert(inputURL: URL, outputURL: URL, format: TTSServerAudioFormat) async throws -> URL {
        try await withCheckedThrowingContinuation { cont in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")

            var arguments = ["-y"]  // Overwrite output file if exists
            arguments += ["-i", inputURL.path]  // Input file

            // Add format-specific arguments
            switch format {
            case .mp3:
                arguments += ["-codec:a", "libmp3lame", "-b:a", "64k"]
            case .opus:
                arguments += ["-codec:a", "libopus", "-b:a", "64k", "-vbr", "on"]
            default:
                break
            }

            arguments += [outputURL.path]
            process.arguments = arguments

            process.terminationHandler = { proc in
                if proc.terminationStatus == 0 {
                    cont.resume(returning: outputURL)
                } else {
                    cont.resume(throwing: TTSServerError.conversionFailed(
                        "ffmpeg exited with code \(proc.terminationStatus)"
                    ))
                }
            }

            do {
                try process.run()
            } catch {
                cont.resume(throwing: TTSServerError.conversionFailed(
                    "ffmpeg failed: \(error.localizedDescription)"
                ))
            }
        }
    }
}
