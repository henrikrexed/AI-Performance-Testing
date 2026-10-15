// @ts-check
// KnightLoad documentation & landing site.
// Observability-driven load testing — "Stop guessing. Load from reality."
//
// Brand: KnightLoad "Signal Diamond". The visual layer (palette tokens, fonts,
// favicons, OG card, Mermaid theme) lives in src/css/custom.css and static/img/.

import {themes as prismThemes} from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'KnightLoad',
  tagline: 'Stop guessing. Load from reality.',
  favicon: 'img/favicon-32.png',

  // Production deploy target (GitHub Pages).
  url: 'https://henrikrexed.github.io',
  baseUrl: '/AI-Performance-Testing/',

  organizationName: 'henrikrexed',
  projectName: 'AI-Performance-Testing',
  deploymentBranch: 'gh-pages',
  trailingSlash: false,

  onBrokenLinks: 'warn',

  // Demo-clip embed gate. Live: the converted assets ship in
  // static/demo/ (approved 27s highlight of the agent-driven loop; see
  // src/components/DemoClip/ASSETS.md for the spec and provenance).
  customFields: {
    demoAssetsReady: true,
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  markdown: {
    mermaid: true,
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },
  themes: [
    '@docusaurus/theme-mermaid',
    [
      // Offline local search — no external account/credentials required.
      '@easyops-cn/docusaurus-search-local',
      /** @type {import('@easyops-cn/docusaurus-search-local').PluginOptions} */
      ({
        hashed: true,
        indexBlog: false,
        docsRouteBasePath: '/docs',
        highlightSearchTermsOnTargetPage: true,
      }),
    ],
  ],

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          editUrl:
            'https://github.com/henrikrexed/AI-Performance-Testing/tree/main/website/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      image: 'img/og-card.png',
      metadata: [
        {
          name: 'description',
          content:
            'KnightLoad turns your observability data into realistic, human-approved load tests — with a mandatory human gate and traffic you can always tell apart.',
        },
        {name: 'keywords', content: 'load testing, observability, k6, JMeter, Gatling, Locust, OpenTelemetry, Dynatrace, performance testing'},
      ],
      colorMode: {
        defaultMode: 'dark',
        respectPrefersColorScheme: true,
      },
      mermaid: {
        theme: {light: 'neutral', dark: 'dark'},
      },
      navbar: {
        title: 'KnightLoad',
        logo: {
          alt: 'KnightLoad',
          src: 'img/logo-horizontal-onlight.png',
          srcDark: 'img/logo-horizontal-onindigo.svg',
          href: '/',
          height: 28,
        },
        items: [
          {to: '/docs/how-it-works', label: 'How it works', position: 'left'},
          {to: '/docs/get-started', label: 'Get started', position: 'left'},
          {to: '/docs/exporters', label: 'Exporters', position: 'left'},
          {
            href: 'https://github.com/henrikrexed/AI-Performance-Testing',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {label: 'How it works', to: '/docs/how-it-works'},
              {label: 'Get started', to: '/docs/get-started'},
              {label: 'Exporters', to: '/docs/exporters'},
            ],
          },
          {
            title: 'Project',
            items: [
              {label: 'GitHub', href: 'https://github.com/henrikrexed/AI-Performance-Testing'},
              {label: 'Releases', href: 'https://github.com/henrikrexed/AI-Performance-Testing/releases'},
              {label: 'Issues', href: 'https://github.com/henrikrexed/AI-Performance-Testing/issues'},
            ],
          },
          {
            title: 'More',
            items: [
              {label: 'Methodology', to: '/docs/how-it-works'},
              {label: 'Examples', href: 'https://github.com/henrikrexed/AI-Performance-Testing/tree/main/examples'},
            ],
          },
        ],
        copyright: `KnightLoad — observability-driven load testing. Docs built with Docusaurus.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        // 'java' must precede 'scala' — Prism's scala grammar extends java.
        additionalLanguages: ['bash', 'json', 'python', 'yaml', 'java', 'scala'],
      },
    }),
};

export default config;
