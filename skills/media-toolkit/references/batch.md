# Batch: playlists and channels

`scripts/yt-batch-transcripts.sh URL` enumerates a playlist or channel with
`--flat-playlist` (no downloads during enumeration), then runs the transcript
script per video into `OUTDIR/<video-id>.txt`.

## Behavior

- **Safety stop:** more than 25 videos exits 4 with `PLAYLIST_TOO_LARGE: N
  videos` on stderr. Tell the user the count and confirm before re-running
  with `-y`. Long channels can be hundreds of videos.
- **Resumable:** completed IDs are recorded in `OUTDIR/.done-transcripts.txt`
  and skipped on re-run, so an interrupted batch continues where it stopped.
- **Per-video failures don't stop the batch** — videos without subtitles are
  reported at the end (`N without subtitles`).

## After the batch

The per-video files are named by video ID. Offer to build an index file
mapping ID → title, or to merge everything into one document, or to run the
analysis the user actually wanted (themes across a channel, quotes per topic).
A channel-transcript corpus is usually research input, not the deliverable.

## Channel URLs

For a channel, prefer the uploads view: `https://www.youtube.com/@handle/videos`.
A bare channel URL may enumerate shorts and live tabs too.
