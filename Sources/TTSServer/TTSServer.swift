import Foundation
import Hummingbird

@main
struct TTSServerApp {
    static func main() async throws {
        let router = Router()
        let generator = TTSServerGenerator()
        let converter = TTSServerAudioConverter()
        let translator = TTSServerTranslator()

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

        // OpenAI Translations API compatible endpoint
        // POST /v1/audio/translations
        router.post("/v1/audio/translations") { request, context -> Response in
            do {
                // Parse multipart form data
                guard let contentType = request.headers[.contentType], !contentType.isEmpty else {
                    return TTSServerError.invalidFile("Missing content type").asResponse
                }

                // Get the body as data - collect all bytes
                var bodyBuffer = ByteBuffer()
                for try await byteBuffer in request.body {
                    bodyBuffer.writeImmutableBuffer(byteBuffer)
                }
                let bodyData = Data(buffer: bodyBuffer)

                // Parse multipart form data manually
                let boundary = contentType.components(separatedBy: "boundary=").last ?? ""
                let parts = parseMultipartFormData(data: bodyData, boundary: boundary)

                // Extract file and model from parts
                guard let fileData = parts["file"]?.data,
                      let filename = parts["file"]?.filename else {
                    return TTSServerError.missingFile.asResponse
                }

                guard let modelData = parts["model"]?.data,
                      let model = String(data: modelData, encoding: .utf8) else {
                    return TTSServerError.missingModel.asResponse
                }

                // Get optional parameters
                let responseFormat: String?
                if let formatData = parts["response_format"]?.data,
                   let formatStr = String(data: formatData, encoding: .utf8),
                   !formatStr.isEmpty {
                    responseFormat = formatStr
                } else {
                    responseFormat = nil
                }

                let finalFormat = responseFormat ?? "json"

                let format: TTSServerTranslationFormat
                if finalFormat == "text" {
                    format = .text
                } else {
                    format = .json
                }

                // Create temporary file for the audio data
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(filename.components(separatedBy: ".").last ?? "wav")

                try fileData.write(to: tempURL)

                // Perform speech recognition
                let transcription = try await translator.recognizeFile(
                    url: tempURL,
                    locale: model
                )

                // Clean up temporary file
                try? FileManager.default.removeItem(at: tempURL)

                // Build response based on format
                var response = Response(status: .ok)

                if format == .json {
                    let jsonResponse = TTSServerTranslationResponse(text: transcription)
                    let jsonData = try JSONEncoder().encode(jsonResponse)
                    response.headers[.contentType] = "application/json"
                    response.body = .init(byteBuffer: .init(data: jsonData))
                } else {
                    response.headers[.contentType] = "text/plain"
                    response.body = .init(byteBuffer: .init(string: transcription))
                }

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

/// Helper struct for multipart form data parts
struct MultipartPart {
    let data: Data
    let filename: String?
}

/// Parses multipart form data
func parseMultipartFormData(data: Data, boundary: String) -> [String: MultipartPart] {
    var parts: [String: MultipartPart] = [:]

    guard !boundary.isEmpty else {
        return parts
    }

    let boundaryData = "--\(boundary)".data(using: .utf8)!
    let headerSeparator = Data([0x0D, 0x0A, 0x0D, 0x0A]) // \r\n\r\n

    // Split by boundary
    let partsData = data.split(separator: boundaryData, omittingEmptySubsequences: true)

    for partData in partsData {
        // Skip if this is the closing boundary (starts with --)
        if partData.starts(with: Data([0x2D, 0x2D])) { // "--"
            continue
        }

        // Find the separator between headers and body
        guard let separatorIndex = partData.range(of: headerSeparator) else {
            // Try \n\n as fallback
            let altSeparator = Data([0x0A, 0x0A])
            guard let altIndex = partData.range(of: altSeparator) else { continue }
            let headerData = partData[partData.startIndex..<altIndex.lowerBound]
            let bodyData = partData[altIndex.upperBound...]
            parsePartBinary(headerData: Data(headerData), bodyData: Data(bodyData), into: &parts)
            continue
        }

        let headerData = partData[partData.startIndex..<separatorIndex.lowerBound]
        let bodyData = partData[separatorIndex.upperBound...]

        parsePartBinary(headerData: Data(headerData), bodyData: Data(bodyData), into: &parts)
    }

    return parts
}

/// Helper function to parse a single multipart part from binary data
func parsePartBinary(headerData: Data, bodyData: Data, into parts: inout [String: MultipartPart]) {
    // Convert headers to string for regex parsing
    guard let headers = String(data: headerData, encoding: .utf8) else { return }

    // Extract name from Content-Disposition
    let nameRegex = try? NSRegularExpression(pattern: "name=\"([^\"]+)\"")
    let nameRange = NSRange(headers.startIndex..., in: headers)
    guard let nameMatch = nameRegex?.firstMatch(in: headers, range: nameRange),
          let nameRangeStr = Range(nameMatch.range(at: 1), in: headers) else {
        return
    }

    let name = String(headers[nameRangeStr])

    // Extract filename if present
    let filenameRegex = try? NSRegularExpression(pattern: "filename=\"([^\"]+)\"")
    var filename: String?
    if let filenameMatch = filenameRegex?.firstMatch(in: headers, range: NSRange(headers.startIndex..., in: headers)),
       let filenameRange = Range(filenameMatch.range(at: 1), in: headers) {
        filename = String(headers[filenameRange])
    }

    // Remove trailing \r\n or \n from body data
    var trimmedBodyData = bodyData
    if trimmedBodyData.count >= 2 {
        let lastTwoBytes = trimmedBodyData.suffix(2)
        if lastTwoBytes == Data([0x0D, 0x0A]) { // \r\n
            trimmedBodyData = Data(trimmedBodyData.dropLast(2))
        } else if trimmedBodyData.count >= 1 {
            let lastByte = trimmedBodyData.suffix(1)
            if lastByte == Data([0x0A]) { // \n
                trimmedBodyData = Data(trimmedBodyData.dropLast(1))
            }
        }
    }

    parts[name] = MultipartPart(data: trimmedBodyData, filename: filename)
}
