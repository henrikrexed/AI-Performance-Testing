// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  docsSidebar: [
    {
      type: 'category',
      label: 'How it works',
      link: {type: 'doc', id: 'how-it-works/index'},
      collapsed: false,
      items: ['how-it-works/index'],
    },
    {
      type: 'category',
      label: 'Get started',
      link: {type: 'doc', id: 'get-started/index'},
      collapsed: false,
      items: [
        'get-started/index',
        'get-started/requirements',
        'get-started/skills-install',
        'get-started/engine',
      ],
    },
    {
      type: 'category',
      label: 'Exporters',
      link: {type: 'doc', id: 'exporters/index'},
      collapsed: false,
      items: [
        'exporters/index',
        'exporters/k6',
        'exporters/jmeter',
        'exporters/gatling',
        'exporters/locust',
      ],
    },
  ],
};

export default sidebars;
