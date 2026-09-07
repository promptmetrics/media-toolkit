#!/usr/bin/env bash
# yt-clip.sh — extract a section of a video. Requires ffmpeg.
# Usage: yt-clip.sh [-o DIR] START END URL   (times like 2:10 or 0:02:10; flags before args)
set -euo pipefail
YTDLP_BIN="${YTDLP_BIN:-yt-dlp}"
outdir="./media-output"
while getopts "o:h" opt; do
  case $opt in
    o) outdir=$OPTARG ;;
    h) echo "usage: yt-clip.sh [-o DIR] START END URL"; exit 0 ;;
    *) exit 2 ;;
  esac
done
shift $((OPTIND - 1))
[ $# -eq 3 ] || { echo "usage: yt-clip.sh [-o DIR] START END URL" >&2; exit 2; }
start=$1; end=$2; url=$3
if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "clip extraction needs ffmpeg, which this session doesn't have. A full-video download still works (yt-download.sh)." >&2
  exit 3
fi
mkdir -p "$outdir"
# Colons don't belong in filenames; keep them only in the section spec.
fstart=${start//:/.}; fend=${end//:/.}
"$YTDLP_BIN" --download-sections "*${start}-${end}" --force-keyframes-at-cuts \
  -f "bv*[height<=1080][ext=mp4]+ba[ext=m4a]/b[ext=mp4][height<=1080]/b" --merge-output-format mp4 \
  --no-warnings -o "$outdir/%(title).60s [%(id)s] ${fstart}-${fend}.%(ext)s" "$url"
