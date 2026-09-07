# Troubleshooting

## Video sites unreachable (bootstrap exit 30)

Most common on a first run: the workspace's egress policy is the default
"Package managers only", which allows PyPI (so yt-dlp installs fine) but
blocks video sites. This is an org-admin setting, not something the user or
the agent can change from inside a session. Relay bootstrap's message
verbatim — it contains the admin steps. The key facts:

- Setting location: claude.ai console -> Organization settings -> Capabilities ->
  Code execution section -> "Domain allowlist" / "Additional allowed domains".
- Keep the dropdown on "Package managers only"; add under Additional allowed
  domains: `youtube.com`, `*.youtube.com`, `*.googlevideo.com`, `*.ytimg.com`.
- Known issue: the specific-domains allowlist is not reliably enforced
  (anthropics/claude-code issues #51400, #30112, #38984); "All domains" is the
  working fallback until fixed.
- Egress is read at session creation: the user must start a NEW session after
  the admin changes it. Re-running in the same session will fail identically.

## ffmpeg missing

Not an error — a capability matrix:

| Works without ffmpeg | Needs ffmpeg |
| --- | --- |
| Transcripts (all modes) | mp3 audio extraction (falls back to m4a) |
| Single-file video download | Merged bestvideo+bestaudio 1080p |
| Batch transcripts | Clip extraction |

## Extractor errors ("Unable to extract ...", "This video is unavailable" on a video that plays in a browser)

YouTube changes its player frequently; yt-dlp's maintainers usually ship a fix
on the nightly channel within a day. Bootstrap installs nightly at every
session start, so the honest answer is: "a site change broke this; try again
in a new session later today or tomorrow — the fix arrives automatically."
Do not retry in a loop within the session; the installed version won't change.

Genuinely unavailable content (private, deleted, region-locked, members-only,
age-gated) fails with its own specific message — relay that as-is.

## "no matches found" when a user runs commands themselves

zsh globbing on the `?` in YouTube URLs. Quote the URL. Inside this skill's
scripts URLs are always quoted, so this only appears in manual terminal use.
