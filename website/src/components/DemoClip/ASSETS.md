# Demo clip assets — how to add them

The landing hero and two docs pages embed short demo recordings through the
`<DemoClip>` component. The embed harness is already wired; it renders a branded
placeholder until the real assets are present and the `demoAssetsReady` flag is
flipped on.

## Shipped assets — provenance

Both clips currently ship the **approved 27 s highlight reel** of the
agent-driven loop (recorded 2026-10-14, board-approved "use this in our
website"): profile generation → V1 confirm → k6/JMeter generation → suggested
scenario → generated k6 script. Source is a normalized 800×508 / 12 fps
capture, so the encodes keep that size instead of 1280×720 — every hard budget
holds (WebM 312 KB, GIF 1.4 MB @ 480 px / 8 fps, poster 120 KB 256-color PNG of
the approved poster frame at 0:22.5).

When a dedicated Clip B recording of the `workload-engine` utility exists (see
`demo/clip-b-utility.md` in the capture kit), drop `utility.*` replacements
into `static/demo/` — no code change needed.

## How to go live

1. Drop the files below into `website/static/demo/`.
2. In `website/docusaurus.config.js`, set `customFields.demoAssetsReady: true`.
3. From `website/`, run `npm run build` and confirm the clips play.
4. From the repo root, run the secret-scan and make sure it exits clean, then
   push — the GitHub Actions Pages deploy publishes the assets.

No code changes are needed to activate the clips — only the files + the flag.

## Required files

Each clip needs three files, keyed by its `name`:

| Clip | `name` | Surface | Files |
|------|--------|---------|-------|
| A — the loop, driven end to end | `hero-loop` | Landing hero | `hero-loop.webm`, `hero-loop.gif`, `hero-loop.poster.png` |
| B — the utility | `utility` | Docs: *How it works* + *Get started* | `utility.webm`, `utility.gif`, `utility.poster.png` |

Naming is exact — the component resolves `/demo/<name>.webm`,
`/demo/<name>.gif`, and `/demo/<name>.poster.png`.

## Web-optimization spec (payload / Lighthouse budget)

| Asset | Format | Target | Hard cap |
|-------|--------|--------|----------|
| `*.webm` (primary) | VP9 or AV1, **no audio track**, yuv420p | ≤ 2 MB | 3 MB |
| `*.gif` (fallback) | 256-color, same crop | ≤ 1.5 MB | 2.5 MB |
| `*.poster.png` | PNG (or JPG), representative frame | ≤ 150 KB | 250 KB |

- **Dimensions:** 16:9, source ≤ 1920×1080, encode at 1280×720 (the embed caps
  display width at 880 px hero / 720 px inline, so 720p is plenty).
- **Duration:** a clean, seamless loop, ideally 8–20 s.
- **Muted:** the WebM must have no audio track (autoplay requires muted).
- **Framerate:** 24–30 fps; drop the GIF to 15 fps to hit its cap.

### Suggested ffmpeg recipes

```sh
# WebM (VP9, no audio, 720p)
ffmpeg -i raw.mov -an -vf "scale=1280:-2,fps=30" \
  -c:v libvpx-vp9 -b:v 0 -crf 34 -row-mt 1 -pix_fmt yuv420p hero-loop.webm

# Poster still (grab a representative frame)
ffmpeg -i raw.mov -vf "scale=1280:-2,select=eq(n\,30)" -frames:v 1 hero-loop.poster.png

# GIF fallback (palette for small size, 15 fps)
ffmpeg -i raw.mov -vf "scale=960:-2,fps=15,palettegen" -y /tmp/pal.png
ffmpeg -i raw.mov -i /tmp/pal.png \
  -lavfi "scale=960:-2,fps=15[x];[x][1:v]paletteuse" hero-loop.gif
```

## Embed behavior (already implemented)

- Primary looping **WebM**, **GIF** fallback for unsupported browsers, plus a
  `<noscript>` GIF for no-JS.
- **Poster** still shown before playback — never a blank box.
- **Lazy:** `preload="none"` + IntersectionObserver; inline clips load only when
  scrolled into view. The hero clip preloads metadata only.
- **`prefers-reduced-motion`: respected** — those users get the poster with
  `<video controls>` (no autoplay, no loop) to opt in.
