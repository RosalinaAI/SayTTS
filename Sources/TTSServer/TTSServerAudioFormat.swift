import Foundation

/// Supported audio formats for TTS output
enum TTSServerAudioFormat: String, Decodable {
    case mp3
    case opus
    case aac
    case flac
    case wav
    case pcm
    case aiff

    /// MIME content type for the format
    var contentType: String {
        switch self {
        case .mp3:
            return "audio/mpeg"
        case .opus:
            return "audio/opus"
        case .aac:
            return "audio/aac"
        case .flac:
            return "audio/flac"
        case .wav:
            return "audio/wav"
        case .pcm:
            return "audio/pcm"
        case .aiff:
            return "audio/aiff"
        }
    }

    /// File extension for the format
    var fileExtension: String {
        switch self {
        case .mp3:
            return "mp3"
        case .opus:
            return "opus"
        case .aac:
            return "aac"
        case .flac:
            return "flac"
        case .wav:
            return "wav"
        case .pcm:
            return "pcm"
        case .aiff:
            return "aiff"
        }
    }

    /// Whether this format is supported on macOS
    /// MP3 and Opus require ffmpeg to be installed
    var isSupported: Bool {
        switch self {
        case .mp3, .opus, .aac, .flac, .wav, .pcm, .aiff:
            return true
        }
    }

    /// afconvert arguments for this format (24kHz mono 16-bit PCM for uncompressed)
    var afconvertArguments: [String] {
        switch self {
        case .mp3, .opus:
            return []  // Not supported, will return error before conversion
        case .aac:
            return ["-f", "m4af", "-d", "aac"]
        case .flac:
            return ["-f", "caff", "-d", "alac"]
        case .wav:
            return ["-f", "WAVE", "-d", "LEI16@24000"]
        case .pcm:
            return ["-f", "WAVE", "-d", "LEI16@24000"]  // Convert to WAV first, then strip header
        case .aiff:
            return []  // No conversion needed - this is say's default output
        }
    }
}
