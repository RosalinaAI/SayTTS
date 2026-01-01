# afconvert

Audio File Convert - convert audio files between formats.

## Syntax

```bash
afconvert [option...] input_file [output_file]
```

```bash
afconvert input_file [-o output_file [option...]]...
```

Options may appear before or after the direct arguments. If `output_file` is not specified, a name is generated programmatically and the file is written into the same directory as `input_file`.

Output file options apply to the previous output_file. Other options may appear anywhere.

## General Options

| Option | Description |
|--------|-------------|
| `-d`, `--data` `data_format[@sample_rate][/format_flags][#frames_per_packet]` | Specify data format.<br>PCM formats: `[-][BE\|LE]{F\|[U]I}{8\|16\|24\|32\|64}` (e.g., `BEI16`, `F32@44100`)<br>Or a data format appropriate to file format (see `-hf`)<br>`format_flags`: hex digits, e.g., `80`<br>`frames_per_packet`: for some encoders, e.g., `samr#12`<br>`0` = same format as source file<br>`N` = native format of lossless encoded source (alac, FLAC only) |
| `-c`, `--channels` `number_of_channels` | Add/remove channels without regard to order |
| `-l`, `--channellayout` `layout_tag` | Layout tag: name of a constant from CoreAudioTypes.h (prefix `kAudioChannelLayoutTag_` may be omitted). If specified once, applies to output file; if twice, the first applies to input, second to output |
| `-b`, `--bitrate` `total_bit_rate_bps` | Total bit rate in bps. e.g., `256000` gives roughly 128000 bps per channel for stereo, or 51000 bps per channel for 5.1 |
| `-q`, `--quality` `codec_quality` | Codec quality: 0-127 |
| `-r`, `--src-quality` `src_quality` | Sample rate converter quality: 0-127 (default: 127) |
| `--src-complexity` `src_complexity` | Sample rate converter complexity: `line`, `norm`, or `bats` |
| `-s`, `--strategy` `strategy` | Bitrate allocation strategy: `0` = CBR, `1` = ABR, `2` = VBR_constrained, `3` = VBR |
| `--prime-method` `method` | Decode priming method (see AudioConverter.h) |
| `--prime-override` `samples_prime samples_remain` | Override priming information stored in source file. Use `-1` to use value from file |
| `--no-filler` | Don't page-align audio data in the output file |
| `--soundcheck-generate` | Analyze audio and add SoundCheck data to output file |
| `--media-kind` `"media kind string"` | Media kinds: `"Audio Ad"`, `"Video Ad"` |
| `--anchor-loudness` | Set anchor loudness of content in dB (single precision float) |
| `--generate-hash` | Generate SHA-1 hash of input audio data and add to output file |
| `--codec-manuf` `codec_manuf` | Specify codec with 4-character component manufacturer code |
| `--dither` `algorithm` | Dither algorithm: 1-2 |
| `--mix` | Enable channel downmixing |
| `-u`, `--userproperty` `property value` | Set arbitrary AudioConverter property. Property is a four-character code; value can be signed 32-bit integer or float. e.g., `-u vbrq sound_quality` (0-127). Not for transcoding |
| `-ud` `property value` | Same as `-u` but only applies to decoder |
| `-ue` `property value` | Same as `-u` but only applies to encoder |

## Input File Options

| Option | Description |
|--------|-------------|
| `--read-track` `track_index` | For files with multiple tracks, specify index (0..n-1) of track to read |
| `--offset` `number_of_frames` | Starting offset in input file in frames (first frame is frame zero) |
| `--soundcheck-read` | Read SoundCheck data from source file and set on destination (.m4a, .caf) |
| `--copy-hash` | Copy SHA-1 hash chunk from source to output file, if present |
| `--gapless-before` `filename` | File coming before current input file of a gapless album |
| `--gapless-after` `filename` | File coming after current input file of a gapless album |

## Output File Options

| Option | Description |
|--------|-------------|
| `-o` `filename` | Specify an (additional) output file |
| `-f`, `--file` `file_format` | Specify file format (use `-hf` for complete list) |
| `--condensed-framing` `field_size_in_bits` | Storage size in bits for externally framed packet sizes. Supported: `16` for AAC in m4a |

## Other Options

| Option | Description |
|--------|-------------|
| `-v`, `--verbose` | Print progress verbosely |
| `-t`, `--tag` | If encoding to CAF, store source format/name in user chunk. If decoding from CAF, use destination format/filename from user chunk |
| `--leaks` | Run leaks at end of conversion |
| `--profile` | Collect and print performance information |

## Help Options

| Option | Description |
|--------|-------------|
| `-hf`, `--help-formats` | Print list of supported file/data formats |
| `-h`, `--help` | Print help |

## Supported File and Data Formats

| File Format | Description | Data Formats |
|-------------|-------------|--------------|
| `3gpp` | 3GP Audio (.3gp) | `Qclp`, `aac `, `aace`, `aacf`, `aach`, `aacl`, `aacp`, `samr` |
| `3gp2` | 3GPP-2 Audio (.3g2) | `Qclp`, `aac `, `aace`, `aacf`, `aach`, `aacl`, `aacp`, `samr` |
| `adts` | AAC ADTS (.aac, .adts) | `aac `, `aach`, `aacp` |
| `ac-3` | AC3 (.ac3) | `ac-3` |
| `AIFC` | AIFC (.aifc, .aiff, .aif) | `I8`, `BEI16`, `BEI24`, `BEI32`, `BEF32`, `BEF64`, `UI8`, `ulaw`, `alaw`, `MAC3`, `MAC6`, `ima4`, `QDMC`, `QDM2`, `Qclp`, `agsm` |
| `AIFF` | AIFF (.aiff, .aif) | `I8`, `BEI16`, `BEI24`, `BEI32` |
| `amrf` | AMR (.amr) | `samr`, `sawb` |
| `m4af` | Apple MPEG-4 Audio - Lossless (.m4a, .m4r) | `aac `, `aace`, `aacf`, `aach`, `aacl`, `aacp`, `ac-3`, `alac`, `ec-3`, `paac`, `pac3`, `qec3`, `zec3` |
| `m4bf` | Apple MPEG-4 AudioBooks (.m4b) | `aac `, `aace`, `aacf`, `aach`, `aacl`, `aacp`, `paac` |
| `caff` | CAF - Apple Core Audio Format (.caf) | `.mp1`, `.mp2`, `.mp3`, `QDM2`, `QDMC`, `Qclp`, `Qclq`, `aac `, `aace`, `aacf`, `aach`, `aacl`, `aacp`, `ac-3`, `alac`, `alaw`, `dvi8`, `ec-3`, `ilbc`, `ima4`, `I8`, `BEI16`, `BEI24`, `BEI32`, `BEF32`, `BEF64`, `LEI16`, `LEI24`, `LEI32`, `LEF32`, `LEF64`, `paac`, `pac3`, `pec3`, `qaac`, `qac3`, `qach`, `qacp`, `qec3`, `samr`, `ulaw`, `zaac`, `zac3`, `zach`, `zacp`, `zec3` |
| `ec-3` | EC3 (.ec3) | `ec-3` |
| `MPG1` | MPEG Layer 1 (.mp1, .mpeg, .mpa) | `.mp1` |
| `MPG2` | MPEG Layer 2 (.mp2, .mpeg, .mpa) | `.mp2` |
| `MPG3` | MPEG Layer 3 (.mp3, .mpeg, .mpa) | `.mp3` |
| `mp4f` | MPEG-4 Audio - Lossy (.mp4) | `aac `, `aace`, `aacf`, `aach`, `aacl`, `aacp`, `ac-3`, `ec-3`, `qec3`, `zec3` |
| `NeXT` | NeXT/Sun (.snd, .au) | `I8`, `BEI16`, `BEI24`, `BEI32`, `BEF32`, `BEF64`, `ulaw` |
| `Sd2f` | Sound Designer II (.sd2) | `I8`, `BEI16`, `BEI24`, `BEI32` |
| `WAVE` | WAVE (.wav) | `UI8`, `LEI16`, `LEI24`, `LEI32`, `LEF32`, `LEF64`, `ulaw`, `alaw` |

## Notes

- Specify data format with `-d` and output file format with `-f`
- Give the new file an appropriate extension—other programs are less forgiving than afconvert
- macOS and afconvert do **not** include an MP3 encoder (though there is an MP4 lossy encoder). Use Lame or iTunes to create MP3s

## Examples

Convert an MP3 file to an iPhone ringtone (M4A):

```bash
afconvert input.mp3 ringtone.m4r --file m4af
```

Convert an AAC file to CAF format at low bitrate:

```bash
afconvert --data aac --bitrate 32000 input.aac output.caf --file caff
```

Convert a WAV file to MP4 with AAC at high bitrate:

```bash
afconvert -d aac -b 256000 input.wav output.mp4 -f mp4f
```
