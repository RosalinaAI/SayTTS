# say

Convert text to audible speech using the Speech Synthesis Manager.

## Synopsis

```bash
say [-v voice] [-r rate] [-o outfile [audio format options] | -n name:port | -a device] [-f file | string ...]
```

## Description

This tool uses the Speech Synthesis manager to convert input text to audible speech and either play it through the sound output device chosen in System Preferences or save it to an audio file.

## Options

### Text Input

| Option | Description |
|--------|-------------|
| `string` | Text to speak on the command line. Can be multiple arguments (separated by spaces) |
| `-f` `file`, `--input-file=file` | File to be spoken. Use `-` to read from standard input |

### Voice Settings

| Option | Description |
|--------|-------------|
| `-v` `voice`, `--voice=voice` | Voice to use. Default is the voice selected in System Preferences. Use `?` to list installed voices |
| `-r` `rate`, `--rate=rate` | Speech rate in words per minute |

### Output Options

| Option | Description |
|--------|-------------|
| `-o` `out.aiff`, `--output-file=file` | Path for audio file to write. AIFF is default and supported by most voices. Some voices support additional formats |
| `-n` `name`, `--network-send=name`<br>`-n` `name:port`<br>`-n` `:port`<br>`-n` `:` | Redirect speech output through AUNetSend. Default service name is `AUNetSend` |
| `-a` `ID`, `--audio-device=ID`<br>`-a` `name`, `--audio-device=name` | Audio device to play audio (by ID or name prefix). Use `?` to list audio output devices |
| `--progress` | Display a progress meter during synthesis |
| `-i`, `--interactive`, `--interactive=markup` | Print text line by line during synthesis, highlighting words as spoken. See markup options below |

### Interactive Mode Markup

The `--interactive` option supports markup styles:

- **Terminfo capability** (e.g., `bold`, `smul`, `setaf 1`)
- **Color name**: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`
- **Foreground/background**: `green/black` (slash-separated, omit foreground for background only)

Default is `smso` (reverse video).

## Audio Formats

Starting in macOS 10.6, file formats other than AIFF may be specified. The file format can often be inferred from the extension, but these options provide finer control:

| Option | Description |
|--------|-------------|
| `--file-format=format` | Format of file to write: `AIFF`, `caff`, `m4af`, `WAVE`. Use `?` to list writable formats |
| `--data-format=format` | Audio data format. For linear PCM: `[BE\|LE][F\|I\|UI]{8\|16\|24\|32\|64}`<br>Others: `aac`, `alac`<br>Optionally append `@samplerate` and `/hexflags`<br>Use `?` to list formats for the specified file format |
| `--channels=channels` | Number of channels (most synthesizers produce mono only) |
| `--bit-rate=rate` | Bit rate for formats like AAC. Use `?` to list valid rates |
| `--quality=quality` | Audio converter quality: 0-127 (lowest to highest) |

## Exit Status

Returns `0` if text was spoken successfully, otherwise non-zero. Diagnostic messages are printed to standard error.

## Behavior

- If input is a TTY: text is spoken line by line, and output file (if specified) contains only audio for the last line
- Otherwise: text is spoken all at once

## Examples

Speak "Hello, World":

```bash
say Hello, World
```

Speak from file using voice "Alex" and save to AIFF:

```bash
say -v Alex -o hi -f hello_world.txt
```

Interactive mode with green highlighting:

```bash
say --interactive=green spending each day the color of the leaves
```

Save to AAC with embedded silence command:

```bash
say -o hi.aac 'Hello, [[slnc 200]] World'
```

Save to M4A with ALAC format:

```bash
say -o hi.m4a --data-format=alac Hello, World.
```

Save to CAF with specific data format:

```bash
say -o hi.caf --data-format=LEF32@8000 Hello, World
```

Query available voices:

```bash
say -v '?'
```

Query available file formats:

```bash
say --file-format=?
```

Query data formats for CAF:

```bash
say --file-format=caff --data-format=?
```

Query available bit rates:

```bash
say -o hi.m4a --bit-rate=?
```
