#!/usr/bin/env bash
# yt-batch-transcripts.sh — transcripts for every video in a playlist or channel.
# Usage: yt-batch-transcripts.sh [-l LANG] [-o DIR] [-y] URL   (flags before URL)
#   -y  skip the >25-item safety stop (the calling agent confirms with the user first)
# Resumable: completed video IDs are recorded in OUTDIR/.done-transcripts.txt and skipped on re-run.
set -euo pipefail
YTDLP_BIN="${YTDLP_BIN:-yt-dlp}"
here="$(cd "$(dirname "$0")" && pwd)"
lang=en; outdir="./media-output"; yes=0
while getopts "l:o:yh" opt; do
  case $opt in
    l) lang=$OPTARG ;;
    o) outdir=$OPTARG ;;
    y) yes=1 ;;
    h) sed -n '2,6p' "$0"; exit 0 ;;
    *) exit 2 ;;
  esac
done
shift $((OPTIND - 1))
[ $# -eq 1 ] || { echo "usage: yt-batch-transcripts.sh [-l LANG] [-o DIR] [-y] URL" >&2; exit 2; }
url=$1
mkdir -p "$outdir"
done_list="$outdir/.done-transcripts.txt"; touch "$done_list"

list="$(mktemp)"; trap 'rm -f "$list"' EXIT
# yt-dlp --print does not interpret \t escapes; build the format with a real tab.
fmt="$(printf '%%(id)s\t%%(title)s')"
"$YTDLP_BIN" --flat-playlist --no-warnings --print "$fmt" "$url" > "$list"
count="$(wc -l < "$list" | tr -d ' ')"
[ "$count" -gt 0 ] || { echo "no videos found at that URL" >&2; exit 1; }
if [ "$count" -gt 25 ] && [ "$yes" -ne 1 ]; then
  echo "PLAYLIST_TOO_LARGE: $count videos. Confirm with the user, then re-run with -y." >&2
  exit 4
fi

ok=0; skipped=0; failed=0
while IFS=$'\t' read -r id title; do
  [ -n "$id" ] || continue
  if grep -qxF "$id" "$done_list"; then skipped=$((skipped+1)); continue; fi
  if "$here/yt-transcript" -l "$lang" -o "$outdir/$id.txt" "https://www.youtube.com/watch?v=$id" 2>/dev/null; then
    echo "$id" >> "$done_list"; ok=$((ok+1)); echo "done: $title"
  else
    failed=$((failed+1)); echo "no transcript: $title ($id)" >&2
  fi
done < "$list"
echo "batch complete: $ok new, $skipped already done, $failed without subtitles (of $count)"
