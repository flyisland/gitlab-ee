import {
  toolCoverageTokens,
  visibleToolCoverageTokens,
} from 'ee/security_inventory/components/tool_coverage_tokens';
import { BUSINESS_LOGIC_KEY } from 'ee/security_inventory/constants';

describe('toolCoverageTokens', () => {
  const [groupToken] = toolCoverageTokens;
  const defaultMatcher = (keyword, query) => keyword.toLowerCase().includes(query.toLowerCase());
  const matches = (query) => groupToken.match({ query, title: groupToken.title, defaultMatcher });
  const findBusinessLogicToken = () =>
    visibleToolCoverageTokens().find(({ type }) => type === BUSINESS_LOGIC_KEY);

  describe('while the bl_security_analyzer flag is off', () => {
    it('does not offer the business logic token', () => {
      expect(findBusinessLogicToken()).toBeUndefined();
      expect(visibleToolCoverageTokens()).toHaveLength(toolCoverageTokens.length - 1);
    });

    it('does not match the tool coverage group on the business logic label', () => {
      expect(matches('Business logic')).toBe(false);
    });
  });

  describe('when the bl_security_analyzer flag is on', () => {
    beforeEach(() => {
      window.gon.features = { blSecurityAnalyzer: true };
    });

    it('offers the business logic token like the other scanner tokens', () => {
      expect(visibleToolCoverageTokens()).toEqual(toolCoverageTokens);
      expect(findBusinessLogicToken()).toMatchObject({
        title: 'Business logic scanning (BL)',
        segmentTitle: 'Business logic scanning',
        unique: true,
        options: expect.arrayContaining([{ value: 'SUCCESS', title: 'Enabled' }]),
      });
    });

    it('matches the tool coverage group on the business logic label', () => {
      expect(matches('Business logic')).toBe(true);
    });
  });
});
