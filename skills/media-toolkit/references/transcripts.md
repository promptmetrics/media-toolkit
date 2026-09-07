# Transcripts

`scripts/yt-transcript` fetches subtitles via yt-dlp and cleans them into
readable prose: strips VTT cue timing and inline word-timing tags, dedupes the
rolling caption lines YouTube auto-captions repeat, and decodes HTML entities
(`&gt;&gt;` speaker markers become `>>`).

Human-written subtitles are preferred automatically; auto-generated captions
are the fallback. Human subs have real punctuation and casing — worth
mentioning when quality matters.

## Flags

| Flag | Meaning |
| --- | --- |
| `-l LANG` | Subtitle language code (default `en`; e.g. `de`, `fr`, `pt`) |
| `-t` | Keep timestamps: one `[hh:mm:ss] text` line per cue |
| `-o FILE` | Write to FILE instead of stdout |

## Patterns

- Default: write to `./media-output/<video-id>.txt` with `-o`, then summarize inline.
- Multi-speaker talks: auto-captions mark speaker changes with `>>`; split on
  those to attribute speakers when the user asks "who said what".
- Timestamps mode (`-t`) is the right base when the user wants to jump back
  into the video ("where do they discuss pricing?").
- Exit 1 = no subtitles in that language. Try `-l` with the video's original
  language before concluding there's no transcript.
