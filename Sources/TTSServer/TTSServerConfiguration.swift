import Foundation
import Configuration

/// Server configuration accessed through Configuration framework
/// Supports environment variable overrides
struct TTSServerConfiguration {
    /// Shared singleton instance
    static let shared = TTSServerConfiguration()

    private let config: ConfigReader

    private init() {
        self.config = ConfigReader(provider: EnvironmentVariablesProvider())
    }

    // MARK: - HTTP Settings

    /// Host address to bind to (default: 127.0.0.1)
    var host: String {
        config.string(forKey: "http.host", default: "127.0.0.1")
    }

    /// Port number to listen on (default: 8080)
    var port: Int {
        config.int(forKey: "http.port", default: 8080)
    }

    // MARK: - FFmpeg Settings

    /// Path to ffmpeg executable (default: /opt/homebrew/bin/ffmpeg)
    var ffmpegPath: String {
        config.string(forKey: "ffmpeg.path", default: "/opt/homebrew/bin/ffmpeg")
    }
}
