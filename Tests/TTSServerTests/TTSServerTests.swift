import Testing
@testable import TTSServer
import Foundation

@Suite("TTSServer Tests")
struct TTSServerTests {

    @Test("TTSServerError provides localized descriptions")
    func testErrorDescriptions() {
        #expect(TTSServerError.invalidModel("tts-2").errorDescription == "Invalid model: tts-2. Supported model is 'tts-1'.")
        #expect(TTSServerError.invalidVoice("bad-voice").errorDescription == "Invalid voice: bad-voice.")
        #expect(TTSServerError.invalidInput("test").errorDescription == "Invalid input: test.")
        #expect(TTSServerError.formatNotSupported("mp3").errorDescription == "Format not supported: mp3.")
        #expect(TTSServerError.conversionFailed("test error").errorDescription == "Audio conversion failed: test error.")
    }

    @Test("TTSServerAudioFormat has correct content types")
    func testAudioFormatContentTypes() {
        #expect(TTSServerAudioFormat.mp3.contentType == "audio/mpeg")
        #expect(TTSServerAudioFormat.opus.contentType == "audio/opus")
        #expect(TTSServerAudioFormat.aac.contentType == "audio/aac")
        #expect(TTSServerAudioFormat.flac.contentType == "audio/flac")
        #expect(TTSServerAudioFormat.wav.contentType == "audio/wav")
        #expect(TTSServerAudioFormat.pcm.contentType == "audio/pcm")
        #expect(TTSServerAudioFormat.aiff.contentType == "audio/aiff")
    }

    @Test("TTSServerAudioFormat has correct file extensions")
    func testAudioFormatExtensions() {
        #expect(TTSServerAudioFormat.mp3.fileExtension == "mp3")
        #expect(TTSServerAudioFormat.opus.fileExtension == "opus")
        #expect(TTSServerAudioFormat.aac.fileExtension == "aac")
        #expect(TTSServerAudioFormat.flac.fileExtension == "flac")
        #expect(TTSServerAudioFormat.wav.fileExtension == "wav")
        #expect(TTSServerAudioFormat.pcm.fileExtension == "pcm")
        #expect(TTSServerAudioFormat.aiff.fileExtension == "aiff")
    }

    @Test("TTSServerAudioFormat support detection")
    func testAudioFormatSupport() {
        #expect(TTSServerAudioFormat.mp3.isSupported == true)  // Requires ffmpeg
        #expect(TTSServerAudioFormat.opus.isSupported == true)  // Requires ffmpeg
        #expect(TTSServerAudioFormat.aac.isSupported == true)
        #expect(TTSServerAudioFormat.flac.isSupported == true)
        #expect(TTSServerAudioFormat.wav.isSupported == true)
        #expect(TTSServerAudioFormat.pcm.isSupported == true)
        #expect(TTSServerAudioFormat.aiff.isSupported == true)
    }

    @Test("TTSServerRequest validation fails for empty input")
    func testRequestValidationEmptyInput() throws {
        let request = TTSServerRequest(
            input: "",
            model: "tts-1",
            voice: nil,
            responseFormat: nil
        )

        #expect(throws: TTSServerError.self) {
            try request.validate()
        }
    }

    @Test("TTSServerRequest validation fails for invalid model")
    func testRequestValidationInvalidModel() throws {
        let request = TTSServerRequest(
            input: "Hello world",
            model: "tts-2",
            voice: nil,
            responseFormat: nil
        )

        var errorThrown = false
        do {
            try request.validate()
        } catch TTSServerError.invalidModel {
            errorThrown = true
        }
        #expect(errorThrown)
    }

    @Test("TTSServerRequest validation fails for input exceeding 4096 characters")
    func testRequestValidationInputTooLong() throws {
        let longInput = String(repeating: "a", count: 4097)
        let request = TTSServerRequest(
            input: longInput,
            model: "tts-1",
            voice: nil,
            responseFormat: nil
        )

        var errorThrown = false
        do {
            try request.validate()
        } catch TTSServerError.invalidInput {
            errorThrown = true
        }
        #expect(errorThrown)
    }

    @Test("TTSServerRequest validation succeeds for valid request")
    func testRequestValidationSuccess() throws {
        let request = TTSServerRequest(
            input: "Hello world",
            model: "tts-1",
            voice: "Alex",
            responseFormat: .aiff
        )

        // Should not throw
        try request.validate()
    }

    @Test("TTSServerRequest decoding from JSON")
    func testRequestDecoding() throws {
        let jsonData = """
        {
            "input": "Hello, world!",
            "model": "tts-1",
            "voice": "Alex",
            "response_format": "aac"
        }
        """.data(using: .utf8)!

        let request = try JSONDecoder().decode(TTSServerRequest.self, from: jsonData)

        #expect(request.input == "Hello, world!")
        #expect(request.model == "tts-1")
        #expect(request.voice == "Alex")
        #expect(request.responseFormat == .aac)
    }

    @Test("TTSServerRequest decoding with default format (nil)")
    func testRequestDecodingDefaultFormat() throws {
        let jsonData = """
        {
            "input": "Hello, world!",
            "model": "tts-1"
        }
        """.data(using: .utf8)!

        let request = try JSONDecoder().decode(TTSServerRequest.self, from: jsonData)

        #expect(request.input == "Hello, world!")
        #expect(request.model == "tts-1")
        #expect(request.responseFormat == nil)
    }

    @Test("TTSServerAudioFormat decoding")
    func testAudioFormatDecoding() throws {
        #expect(try JSONDecoder().decode(TTSServerAudioFormat.self, from: Data("\"mp3\"".utf8)) == .mp3)
        #expect(try JSONDecoder().decode(TTSServerAudioFormat.self, from: Data("\"opus\"".utf8)) == .opus)
        #expect(try JSONDecoder().decode(TTSServerAudioFormat.self, from: Data("\"aac\"".utf8)) == .aac)
        #expect(try JSONDecoder().decode(TTSServerAudioFormat.self, from: Data("\"flac\"".utf8)) == .flac)
        #expect(try JSONDecoder().decode(TTSServerAudioFormat.self, from: Data("\"wav\"".utf8)) == .wav)
        #expect(try JSONDecoder().decode(TTSServerAudioFormat.self, from: Data("\"pcm\"".utf8)) == .pcm)
        #expect(try JSONDecoder().decode(TTSServerAudioFormat.self, from: Data("\"aiff\"".utf8)) == .aiff)
    }
}
