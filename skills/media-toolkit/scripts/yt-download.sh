#!/usr/bin/env bash
# yt-download.sh — download video (default) or audio (-a) with operator-safe defaults.
# Usage: yt-download.sh [-a] [-o DIR] URL     (flags before URL; quote the URL)
set -euo pipefail
YTDLP_BIN="${YTDLP_BIN:-yt-dlp}"
audio=0; outdir="./media-output"
while getopts "ao:h" opt; do
  case $opt in
    a) audio=1 ;;
    o) outdir=$OPTARG ;;
    h) echo "usage: yt-download.sh [-a] [-o DIR] URL"; exit 0 ;;
    *) exit 2 ;;
  esac
done
shift $((OPTIND - 1))
[ $# -eq 1 ] || { echo "usage: yt-download.sh [-a] [-o DIR] URL" >&2; exit 2; }
url=$1
mkdir -p "$outdir"
tpl="$outdir/%(title).80s [%(id)s].%(ext)s"

ffmpeg_ok=0; command -v ffmpeg >/dev/null 2>&1 && ffmpeg_ok=1

if [ "$audio" -eq 1 ]; then
  if [ "$ffmpeg_ok" -eq 1 ]; then
    "$YTDLP_BIN" -x --audio-format mp3 --no-warnings -o "$tpl" "$url"
  else
    echo "note: ffmpeg missing — saving original m4a audio instead of mp3" >&2
    "$YTDLP_BIN" -f "ba[ext=m4a]/ba" --no-warnings -o "$tpl" "$url"
  fi
else
  if [ "$ffmpeg_ok" -eq 1 ]; then
    "$YTDLP_BIN" -f "bv*[height<=1080][ext=mp4]+ba[ext=m4a]/b[ext=mp4][height<=1080]/b" \
      --merge-output-format mp4 --no-warnings -o "$tpl" "$url"
  else
    echo "note: ffmpeg missing — using best single-file quality (may be below 1080p)" >&2
    "$YTDLP_BIN" -f "b[ext=mp4][height<=1080]/b" --no-warnings -o "$tpl" "$url"
  fi
fi
