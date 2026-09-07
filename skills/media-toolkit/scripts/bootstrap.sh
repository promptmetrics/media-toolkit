#!/usr/bin/env bash
# bootstrap.sh — prepare the sandbox for media operations. Run before the first
# media operation of every session. Idempotent; safe to re-run.
# Exit codes: 0 ok | 10 no python | 20 yt-dlp install failed | 30 video-site egress blocked.
# The calling agent relays any non-zero exit's message to the user verbatim and stops.
set -uo pipefail

say() { printf '%s\n' "$*"; }

if ! command -v python3 >/dev/null 2>&1; then
  say "This environment has no Python 3, so the media tools can't be installed."
  say "Ask your Claude admin to enable code execution for Cowork, then start a new session."
  exit 10
fi

# Runtime self-update: reinstall from PyPI every session on the nightly channel (--pre).
# Extractor fixes ship on nightly roughly daily; stable can lag by weeks.
if ! python3 -m pip install --quiet --upgrade --pre "yt-dlp[default]" 2>/dev/null; then
  if ! python3 -m pip install --quiet --upgrade --pre --user "yt-dlp[default]" 2>/dev/null; then
    say "Couldn't install yt-dlp from PyPI."
    say "Your Claude admin needs to allow package-manager network access:"
    say "claude.ai console -> Organization settings -> Capabilities -> Code execution -> Allow network egress -> at least 'Package managers only'."
    say "Egress applies to sessions created after the change, so start a new session afterwards."
    exit 20
  fi
fi

YTDLP_BIN="$(command -v yt-dlp || true)"
[ -n "$YTDLP_BIN" ] || YTDLP_BIN="$HOME/.local/bin/yt-dlp"
if ! "$YTDLP_BIN" --version >/dev/null 2>&1; then
  say "yt-dlp installed but isn't runnable. Diagnostic for a bug report: python3 -m pip show yt-dlp"
  exit 20
fi
export YTDLP_BIN
say "yt-dlp $("$YTDLP_BIN" --version) ready ($YTDLP_BIN)"

if command -v ffmpeg >/dev/null 2>&1; then
  export FFMPEG_OK=1
  say "ffmpeg present — full toolkit available"
else
  export FFMPEG_OK=0
  say "ffmpeg missing — transcripts and standard downloads work; mp3 audio extraction, merged 1080p video, and clip cutting are unavailable this session."
fi

code="$(curl -sIL -m 8 -o /dev/null -w '%{http_code}' https://www.youtube.com/ || echo 000)"
case "$code" in
  2*|3*) say "network check ok (youtube.com reachable)" ;;
  *)
    say "This workspace can't reach video sites yet. Copy this to your Claude admin:"
    say ""
    say "  Please allow media downloads for our Cowork workspace."
    say "  Where: claude.ai console -> Organization settings -> Capabilities -> Code execution -> Allow network egress."
    say "  The default 'Package managers only' setting blocks video sites."
    say "  Domains needed: youtube.com, www.youtube.com, *.googlevideo.com, i.ytimg.com"
    say "  Known issue: the specific-domains allowlist is not reliably enforced right now"
    say "  (github.com/anthropics/claude-code issues #51400, #30112, #38984)."
    say "  If adding domains doesn't take effect, set egress to 'All domains' for this workspace."
    say "  Egress is read when a session starts — start a NEW Cowork session after changing it."
    exit 30
    ;;
esac
exit 0
