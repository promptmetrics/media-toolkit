# Media Toolkit

Turn video URLs into transcripts, files, and clips from inside [Claude Cowork](https://claude.com/docs/cowork/overview) — built for operators who never want to open a terminal. Powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp).

## Why This Plugin

Paste a YouTube link into a Cowork session and ask in plain language. The plugin handles the tooling — installing its engine, keeping it current, and telling you (or your admin) exactly what to do when something needs a setting changed. Works on any of yt-dlp's 1800+ supported sites, not just YouTube.

## What It Does

| Ask Claude | What you get |
| --- | --- |
| "Get the transcript of this video" | Clean prose — human captions preferred, timestamps optional, any language |
| "Download this video" | mp4 at up to 1080p in your session files |
| "Download the audio" | mp3 |
| "Pull the clip from 2:10 to 3:45" | Just that section as mp4 |
| "Transcripts for this playlist" | One file per video — batch, resumable, with a safety stop on large channels |

## Getting Started

### Cowork

1. Open Cowork → **Customize** in the sidebar → **Plugins**
2. **Add marketplace** → paste `promptmetrics/media-toolkit`
3. Find **media-toolkit** → **Install**
4. In a session, paste a video URL and ask for what you need

Updates arrive through the **Update** button on the same screen.

### Cowork (org admins)

Two settings in the [claude.ai console](https://claude.ai), both under **Organization settings**:

1. **Distribute the plugin:** Organization settings → **Plugins** → add marketplace `promptmetrics/media-toolkit` → set **media-toolkit** to *Installed by default* (or *Required*).
2. **Allow network access to video sites — the plugin cannot download anything without this.** Organization settings → **Capabilities** → **Code execution** section. Keep the *Domain allowlist* dropdown on *Package managers only* (that lets the plugin install its engine) and add these under **Additional allowed domains**:

```
youtube.com
*.youtube.com
*.googlevideo.com
*.ytimg.com
```

Known issue: additional domains are not reliably enforced right now ([#51400](https://github.com/anthropics/claude-code/issues/51400), [#30112](https://github.com/anthropics/claude-code/issues/30112), [#38984](https://github.com/anthropics/claude-code/issues/38984)) — if they don't take effect, switch the dropdown to *All domains* until those are fixed. Network settings apply to sessions created after the change, so start a new session to test.

If network access is still closed, the plugin doesn't fail cryptically — it hands the user a copy-paste message for you with these exact steps.

### Claude Code

```
/plugin marketplace add promptmetrics/media-toolkit
/plugin install promptmetrics-media-toolkit@media-toolkit
```

### Zip upload (fallback)

No GitHub access from your org? Run `scripts/build-zip.sh` and upload `dist/media-toolkit.zip` on the Plugins page (well under the 50 MB limit).

## How It Works

```
media-toolkit/
├── .claude-plugin/          # Plugin + marketplace manifests
├── skills/media-toolkit/
│   ├── SKILL.md             # Routing: which request runs which script
│   ├── references/          # Detail docs Claude loads on demand
│   └── scripts/
│       ├── bootstrap.sh     # Per-session setup: install engine, probe ffmpeg + network
│       ├── yt-transcript    # Subtitles → clean prose
│       ├── yt-download.sh   # Video / audio with safe defaults
│       ├── yt-clip.sh       # Section extraction
│       └── yt-batch-transcripts.sh
└── tests/                   # Fixture VTT + stub engine for deterministic CI
```

**Updates need nothing from you.** The engine (yt-dlp) is never bundled or pinned: at the start of every session, `bootstrap.sh` reinstalls it from PyPI on the nightly channel — yt-dlp's own recommended channel, where fixes for site changes land within a day. When YouTube breaks something, the fix reaches your sessions automatically.

The plugin itself releases through version bumps (CI enforces them), which is what triggers Cowork's marketplace sync. A weekly canary smoke-tests the pipeline and real downloads, and opens an issue here when something breaks upstream.

## Making It Yours

- **Change the defaults** — Resolution caps, output formats, and the batch safety limit live in `skills/media-toolkit/scripts/`; each script is a short, readable bash file.
- **Add sites** — Nothing here is YouTube-specific except the network domains; add your admin-approved domains for other yt-dlp-supported sites.
- **Transcript-only CLI** — The transcript logic also ships standalone at [promptmetrics/yt-transcript](https://github.com/promptmetrics/yt-transcript) for people who do like terminals.

## Usage and Content Rights

yt-dlp is a general-purpose downloader that runs entirely inside your own Cowork sandbox. PromptMetrics hosts no content and proxies no traffic — this plugin is instructions and shell scripts.

YouTube's Terms of Service restrict downloading content except where YouTube provides a download control. Whether a given download is permitted depends on the content's license (your own uploads, Creative Commons material, content you hold rights to) and your jurisdiction. Your organization is responsible for its own use.

The MIT license covers this code, not the media you fetch with it.

## Contributing

Issues and PRs welcome. Any change to `skills/` or the manifests must bump the version in both `plugin.json` and `marketplace.json` — CI blocks the merge otherwise.

Built by [Izzy Aly](https://github.com/iiizzzyyy) at [PromptMetrics](https://github.com/promptmetrics).

## License

[MIT](LICENSE)
