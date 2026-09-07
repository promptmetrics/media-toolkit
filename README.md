# media-toolkit

A Claude plugin that turns video URLs into transcripts, files, and clips — built for operators who work in [Claude Cowork](https://claude.com/docs/cowork/overview) and never want to open a terminal. Powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp).

Paste a YouTube link into a Cowork session and ask:

- "Get me the transcript of this video" — clean prose, human captions preferred, timestamps optional
- "Download this as audio" — mp3 into your session files
- "Pull the clip from 2:10 to 3:45"
- "Transcripts for this whole playlist" — batch, resumable, with a safety stop on large channels

Works on any of yt-dlp's 1800+ supported sites, not just YouTube.

## Install (individual, no terminal)

1. Open Cowork → **Customize** in the sidebar → **Plugins**
2. **Add marketplace** → paste `promptmetrics/media-toolkit`
3. Find **media-toolkit** → **Install**
4. In a session, paste a video URL and ask for what you need

Updates: same screen → **Update** on the marketplace.

## Org rollout (admin — read this first)

Two settings, both in the [claude.ai console](https://claude.ai):

**1. Distribute the plugin.** Organization settings → Plugins → add marketplace `promptmetrics/media-toolkit` → set **media-toolkit** to *Installed by default* (or *Required*).

**2. Open network egress for video sites — the plugin is dead on arrival without this.** Organization settings → Cowork → Code execution → Allow network egress. The default *Package managers only* setting lets the plugin install its engine but blocks the actual video sites. Domains needed:

```
youtube.com
www.youtube.com
*.googlevideo.com
i.ytimg.com
```

Known issue: the specific-domains allowlist is currently not reliably enforced ([#51400](https://github.com/anthropics/claude-code/issues/51400), [#30112](https://github.com/anthropics/claude-code/issues/30112), [#38984](https://github.com/anthropics/claude-code/issues/38984)) — if adding domains doesn't take effect, use *All domains* until those are fixed. Egress is read at session creation, so users must start a new session after the change.

If egress is still closed, the plugin doesn't error out cryptically — it hands the user a copy-paste message for you with these exact steps.

## Zip upload (fallback)

No GitHub access from your org? Run `scripts/build-zip.sh` and upload `dist/media-toolkit.zip` on the Plugins page (the zip is well under the 50 MB limit).

## Claude Code

```
/plugin marketplace add promptmetrics/media-toolkit
/plugin install promptmetrics-media-toolkit@media-toolkit
```

## How updates work

**yt-dlp** (the engine) is never bundled or pinned. At the start of every session the skill reinstalls it from PyPI on the **nightly channel** — yt-dlp's own recommended channel, where extractor fixes land within a day of a site change. When YouTube breaks something, the fix reaches your sessions automatically; no plugin update, no action from you.

**The plugin itself** releases through version bumps: every behavior change bumps the version in both manifests (CI enforces it), which is what triggers Cowork's org GitHub sync and lights up the marketplace Update button.

**The canary** (`.github/workflows/canary.yml`) smoke-tests a real transcript and a real download weekly against stable public-domain/CC fixtures and opens a GitHub issue if YouTube breaks something upstream — so we usually know before you notice.

## Usage and content rights

yt-dlp is a general-purpose downloader that runs entirely inside your own Cowork sandbox. PromptMetrics hosts no content and proxies no traffic — this plugin is instructions and shell scripts.

YouTube's Terms of Service restrict downloading content except where YouTube provides a download control. Whether a given download is permitted depends on the content's license (your own uploads, Creative Commons material, content you hold rights to) and your jurisdiction. Your organization is responsible for its own use.

The MIT license below covers this code, not the media you fetch with it.

## Related

- [promptmetrics/yt-transcript](https://github.com/promptmetrics/yt-transcript) — the standalone CLI version of the transcript tool, for people who *do* like terminals.

## License

[MIT](LICENSE)
