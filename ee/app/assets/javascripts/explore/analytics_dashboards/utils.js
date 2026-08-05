import { getUniquePanelId } from '~/explore/analytics_dashboards/utils';

export const wrapGlqlInVisualization = (glql) => ({
  type: 'Glql',
  options: {},
  data: {
    type: 'glql',
    query: {
      glql,
    },
  },
});

export const wrapVisualizationInPanel = (visualization) => ({
  id: getUniquePanelId(),
  visualization,
  gridAttributes: {
    width: 6,
    height: 3,
  },
});
