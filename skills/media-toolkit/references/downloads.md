# Downloads and clips

## Video — `scripts/yt-download.sh`

Defaults: best mp4 at or below 1080p, video+audio merged (needs ffmpeg).
Without ffmpeg it automatically uses the best single-file format and says so.
Output name: `Title [video-id].mp4`, truncated to a sane length.

## Audio — `scripts/yt-download.sh -a`

mp3 when ffmpeg is present; original m4a otherwise (the script prints which).
Good enough for podcast-style listening and for transcription pipelines.

## Clips — `scripts/yt-clip.sh START END URL`

Times as `2:10`, `0:02:10`, or seconds. Wraps yt-dlp's
`--download-sections "*START-END" --force-keyframes-at-cuts`, so cut points
are accurate to the nearest keyframe (typically within a second or two).
Requires ffmpeg — the script exits 3 with a plain message if it's missing;
offer a full download instead.

## Notes

- Everything defaults into `./media-output/`; override with `-o DIR`.
- File sizes: a 10-minute 1080p video is typically 100–300 MB. For long videos,
  ask the user whether audio-only or a clip serves the actual need before
  pulling gigabytes into the sandbox.
- These scripts work on any yt-dlp-supported site (1800+), not just YouTube.
