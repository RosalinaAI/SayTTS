# SayTTS

OpenAI Speech API compatible Text-to-Speech server for macOS using the built-in `say` command.

## Requirements

- macOS 14.0+
- Xcode Command Line Tools (for `swift` and `afconvert`)

## Building

```bash
swift build
```

## Running

```bash
swift run
```

The server defaults to `http://127.0.0.1:8080`

### Configuration

The server host and port can be configured via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `HTTP_HOST` | `127.0.0.1` | Host address to bind to |
| `HTTP_PORT` | `8080` | Port number to listen on |

Example:

```bash
HTTP_HOST=0.0.0.0 HTTP_PORT=3000 swift run
```

## API Endpoint

### POST /v1/audio/speech

Generate audio from text.

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `input` | string | Yes | Text to convert to speech (max 4096 characters) |
| `model` | string | Yes | Must be `"tts-1"` (validated, no effect on output) |
| `voice` | string | No | Voice name (e.g., "Alex", "Samantha"). Defaults to system voice. |
| `response_format` | string | No | Audio format. Default: `"mp3"` |

**Response:** Audio file with appropriate `Content-Type` header.

## Supported Formats

| Format | Supported | Description |
|--------|-----------|-------------|
| **aac** | Yes | Digital audio compression, preferred by YouTube, Android, iOS |
| **flac** | Yes | Lossless audio compression for archiving |
| **wav** | Yes | Uncompressed WAV at 24kHz mono, 16-bit PCM |
| **pcm** | Yes | Raw 24kHz mono, 16-bit signed little-endian samples (no header) |
| **aiff** | Yes | Default output from `say` command |
| **mp3** | **No** | Not available on macOS without LAME encoder |
| **opus** | **No** | Not available on macOS |

> Note: MP3 and Opus return error `"Format not supported"` because macOS does not include encoders for these formats.

## Usage Examples

### Generate AIFF audio (default voice)

```bash
curl -X POST http://127.0.0.1:8080/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "input": "Hello, world!",
    "model": "tts-1",
    "response_format": "aiff"
  }' \
  --output speech.aiff
```

### Use a specific voice

```bash
# List available voices: say -v '?'
curl -X POST http://127.0.0.1:8080/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "input": "The quick brown fox jumps over the lazy dog.",
    "model": "tts-1",
    "voice": "Samantha",
    "response_format": "aac"
  }' \
  --output speech.aac
```

### Generate WAV format (24kHz uncompressed)

```bash
curl -X POST http://127.0.0.1:8080/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "input": "This is uncompressed audio.",
    "model": "tts-1",
    "response_format": "wav"
  }' \
  --output speech.wav
```

### Generate raw PCM (24kHz, 16-bit signed little-endian)

```bash
curl -X POST http://127.0.0.1:8080/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "input": "Raw PCM data without headers.",
    "model": "tts-1",
    "response_format": "pcm"
  }' \
  --output speech.pcm
```

### Generate FLAC (lossless)

```bash
curl -X POST http://127.0.0.1:8080/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "input": "Lossless compressed audio.",
    "model": "tts-1",
    "response_format": "flac"
  }' \
  --output speech.flac
```

## Testing

Run the test suite:

```bash
swift test
```

## Error Responses

| Error | Description |
|-------|-------------|
| `Invalid model` | Model must be `"tts-1"` |
| `Invalid input` | Input text is empty or exceeds 4096 characters |
| `Format not supported` | Requested mp3 or opus format |
| `Say command failed` | Underlying `say` command error |
| `Audio conversion failed` | `afconvert` conversion error |

## License

MIT
