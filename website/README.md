# KnightLoad documentation & landing site

The public site for **KnightLoad** — observability-driven load testing. Built with
[Docusaurus](https://docusaurus.io/) (+ `@docusaurus/theme-mermaid`), deployed to GitHub
Pages at `https://henrikrexed.github.io/AI-Performance-Testing/`.

The docs reuse the toolkit's own documentation (`../docs/*`) and methodology.

## Local development

```sh
cd website
npm install
npm start          # dev server with hot reload
npm run build      # production build -> build/
npm run serve      # preview the production build locally
```

Node 20+ is required. Diagrams are Mermaid (rendered client-side); search is offline/local
(`@easyops-cn/docusaurus-search-local`, no external account).

## Structure

```
website/
  docusaurus.config.js   # site config, navbar, footer, Mermaid + search themes
  sidebars.js            # How it works · Get started · Exporters
  src/
    pages/index.js       # landing page (hero, loop diagram, differentiators, exporters, CTAs)
    css/custom.css       # brand layer — palette tokens, fonts, Mermaid theme
  docs/
    how-it-works/        # five stages, V1 gate, components (two Mermaid diagrams)
    get-started/         # quickstart + requirements / skills-install / engine
    exporters/           # overview + k6 / jmeter / gatling / locust
  static/img/            # brand assets — logo lockups, favicons, OG card
```

## Brand assets

The KnightLoad "Signal Diamond" brand lives in two places:

- **Tokens & type** — `src/css/custom.css` (`--kl-*` palette, light/dark Infima variables,
  Space Grotesk / Sora fonts, the `.kl-wordmark` two-tone helper).
- **Images** — `static/img/` (navbar lockups `logo-horizontal*`, favicons, `og-card.png`).

The site display name is **KnightLoad**; the wordmark is two-tone — `Knight` in silver,
`load` in the accent colour.

## Deploy

`.github/workflows/deploy-pages.yml` (repo root) builds `website/` and deploys to GitHub
Pages on push to `main`.

**One-time repo-admin setup:** Settings → Pages → Build and deployment → Source →
*GitHub Actions*. The deploy uses the built-in `GITHUB_TOKEN`; no personal access token is
needed for the deploy itself.
