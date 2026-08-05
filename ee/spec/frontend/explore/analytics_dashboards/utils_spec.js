import {
  wrapGlqlInVisualization,
  wrapVisualizationInPanel,
} from 'ee/explore/analytics_dashboards/utils';

describe('EE Analytics Dashboards utils', () => {
  describe('wrapGlqlInVisualization', () => {
    it('wraps a GLQL query in a Glql visualization config', () => {
      const glql = 'assignee = currentUser()';

      expect(wrapGlqlInVisualization(glql)).toEqual({
        type: 'Glql',
        options: {},
        data: {
          type: 'glql',
          query: {
            glql,
          },
        },
      });
    });
  });

  describe('wrapVisualizationInPanel', () => {
    const visualization = { type: 'Glql', options: {} };

    it('wraps a visualization in a panel with default grid attributes', () => {
      expect(wrapVisualizationInPanel(visualization)).toMatchObject({
        visualization,
        gridAttributes: {
          width: 6,
          height: 3,
        },
      });
    });

    it('assigns a unique panel id', () => {
      const panelOne = wrapVisualizationInPanel(visualization);
      const panelTwo = wrapVisualizationInPanel(visualization);

      expect(panelOne.id).toMatch(/^panel-\d+$/);
      expect(panelTwo.id).toMatch(/^panel-\d+$/);
      expect(panelOne.id).not.toBe(panelTwo.id);
    });
  });
});
