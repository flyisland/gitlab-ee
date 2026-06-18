import {
  projectSettingsValidator,
  getProjectSettingsValidationErrors,
} from 'ee/product_analytics/onboarding/components/providers/utils';

describe('product analytics onboarding provider utils', () => {
  describe('projectSettingsValidator', () => {
    const validProp = {
      productAnalyticsConfiguratorConnectionString: 'https://test:test@configurator.example.com',
      productAnalyticsDataCollectorHost: 'https://collector.example.com',
      cubeApiBaseUrl: 'https://cube.example.com',
      cubeApiKey: '123-some-cube-key',
    };
    const { cubeApiKey, ...propMissingCube } = validProp;

    const testCases = [
      ['valid settings', validProp, true],
      ['null value', { ...validProp, cubeApiKey: null }, true],
      ['missing property', propMissingCube, false],
      ['unexpected property', { ...validProp, someUnexpectedProp: 'test' }, false],
      ['invalid value type', { ...validProp, cubeApiKey: 123 }, false],
      ['empty object', {}, false],
    ];

    it.each(testCases)('%s', (_, prop, expected) => {
      expect(projectSettingsValidator(prop)).toBe(expected);
    });
  });

  describe('getProjectSettingsValidationErrors', () => {
    const validPayload = {
      productAnalyticsConfiguratorConnectionString: 'https://configurator.example.com',
      productAnalyticsDataCollectorHost: 'https://collector.example.com',
      cubeApiBaseUrl: 'https://cube.example.com',
      cubeApiKey: 'abc',
    };

    it.each`
      payload                                                                     | expected
      ${{ productAnalyticsConfiguratorConnectionString: 'not-a-url' }}            | ${{ productAnalyticsConfiguratorConnectionString: 'Enter a valid URL' }}
      ${{ productAnalyticsConfiguratorConnectionString: '/not/an/absolute/url' }} | ${{ productAnalyticsConfiguratorConnectionString: 'Enter a valid URL' }}
      ${{ productAnalyticsConfiguratorConnectionString: '' }}                     | ${{ productAnalyticsConfiguratorConnectionString: 'This field is required' }}
      ${{ productAnalyticsDataCollectorHost: 'not-a-url' }}                       | ${{ productAnalyticsDataCollectorHost: 'Enter a valid URL' }}
      ${{ productAnalyticsDataCollectorHost: '/not/an/absolute/url' }}            | ${{ productAnalyticsDataCollectorHost: 'Enter a valid URL' }}
      ${{ productAnalyticsDataCollectorHost: '' }}                                | ${{ productAnalyticsDataCollectorHost: 'This field is required' }}
      ${{ cubeApiBaseUrl: 'not-a-url' }}                                          | ${{ cubeApiBaseUrl: 'Enter a valid URL' }}
      ${{ cubeApiBaseUrl: '/not/an/absolute/url' }}                               | ${{ cubeApiBaseUrl: 'Enter a valid URL' }}
      ${{ cubeApiBaseUrl: '' }}                                                   | ${{ cubeApiBaseUrl: 'This field is required' }}
      ${{ cubeApiKey: '' }}                                                       | ${{ cubeApiKey: 'This field is required' }}
      ${{}}                                                                       | ${{}}
    `('returns $expected for $payload', ({ expected, payload }) => {
      expect(getProjectSettingsValidationErrors({ ...validPayload, ...payload })).toEqual(expected);
    });
  });
});
