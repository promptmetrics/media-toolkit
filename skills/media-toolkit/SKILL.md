---
name: media-toolkit
description: >
  YouTube and media operations via yt-dlp inside a Cowork or Claude Code sandbox.
  Use when the user says "get the transcript", "download this video", "download
  the audio", "pull this clip", "clip from 2:10 to 3:45", "transcribe this
  YouTube link", "transcripts for this playlist" or "for this channel", or
  pastes a youtube.com / youtu.be / other video URL asking for its content as
  text or a file. Do NOT use for YouTube strategy, SEO, scripting, thumbnails,
  or analytics questions (nothing to download), for media files the user
  uploads directly, or for live streams still in progress.
license: MIT
metadata:
  author: PromptMetrics
  version: 0.1.0
---

# Media Toolkit

Wraps [yt-dlp](https://github.com/yt-dlp/yt-dlp) so an operator can turn video
URLs into transcripts, files, and clips by asking in plain language. All script
paths below are relative to this skill's directory.

## 1. Bootstrap first — every session

Before the first media operation of a session, run:

```bash
bash scripts/bootstrap.sh
```

It installs/refreshes yt-dlp from PyPI (nightly channel — this is how the
toolkit stays current with upstream releases), probes for ffmpeg, and checks
that video sites are reachable from this sandbox.

**If it exits non-zero, relay its printed message to the user verbatim and
stop.** Do not retry, do not paraphrase into something vaguer, and never show a
raw error or stack trace. Exit meanings: `10` no Python, `20` PyPI blocked,
`30` video sites blocked — `30` is the most common first-run outcome on a
default workspace, and the message includes a copy-paste block for the user's
org admin.

## 2. Routing

| The user wants | Run | Reference |
| --- | --- | --- |
| Transcript of one video | `scripts/yt-transcript [-l LANG] [-t] [-o FILE] URL` | `references/transcripts.md` |
| Video file | `scripts/yt-download.sh [-o DIR] URL` | `references/downloads.md` |
| Audio only | `scripts/yt-download.sh -a [-o DIR] URL` | `references/downloads.md` |
| A clip/section | `scripts/yt-clip.sh [-o DIR] START END URL` | `references/downloads.md` |
| Transcripts for a playlist/channel | `scripts/yt-batch-transcripts.sh [-l LANG] [-o DIR] [-y] URL` | `references/batch.md` |

Flags always go before the URL, and always quote the URL.

## 3. Outputs

Everything lands in `./media-output/` in the session workspace. After each
operation, tell the user the exact filename(s) and that the files appear in
Cowork's file panel for download. For transcripts, offer a summary or the
specific extraction they need (quotes, action items, chapters) — pulling
insight out of the transcript is usually the real job, not the raw text.

## 4. Degradation rules

- **No ffmpeg** (bootstrap reports it): transcripts and standard downloads
  work; mp3 extraction falls back to m4a; merged 1080p falls back to best
  single-file quality; clips are unavailable — offer a full download instead.
- **Extractor errors** (yt-dlp can't parse a page): tell the user "YouTube
  changed something on their side; yt-dlp usually ships a fix within a day,
  and a new session picks it up automatically." Details in
  `references/troubleshooting.md`.
- **No subtitles** on a video: the transcript script exits 1 with a clear
  message; relay it and note that a video with no captions has no transcript
  to fetch.

## 5. Guardrails

- Batch runs stop at 25 videos (`PLAYLIST_TOO_LARGE` on stderr). Confirm the
  full count with the user before re-running with `-y`.
- Never attempt to work around the workspace's network policy; the admin
  message in bootstrap is the only path.
- Content rights sit with the operator and their org — the README's usage
  section is the reference if the user asks.
