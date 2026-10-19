import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import RuleList from 'ee/security_orchestration/components/policy_editor/dependency_firewall/rule/rule_list.vue';
import FixedRuleCard from 'ee/security_orchestration/components/policy_editor/dependency_firewall/components/fixed_rule_card.vue';

describe('RuleList', () => {
  let wrapper;

  const createWrapper = (rules = [], glFeatures = {}) => {
    wrapper = shallowMountExtended(RuleList, { propsData: { rules }, provide: { glFeatures } });
  };

  const findAllCards = () => wrapper.findAllComponents(FixedRuleCard);
  const findCard = (type) => findAllCards().wrappers.find((card) => card.props('type') === type);

  it('renders malicious, vulnerability, and license when the risk_severity flag is off', () => {
    createWrapper([], { dependencyFirewallRiskSeverityRule: false });
    const types = findAllCards().wrappers.map((card) => card.props('type'));

    expect(types).toEqual(['malicious', 'vulnerability', 'license']);
  });

  it('renders risk_severity instead of vulnerability when the flag is on, never both', () => {
    createWrapper([], { dependencyFirewallRiskSeverityRule: true });
    const types = findAllCards().wrappers.map((card) => card.props('type'));

    expect(types).toEqual(['malicious', 'risk_severity', 'license']);
  });

  it.each([true, false])(
    'keeps the label "Known vulnerabilities" regardless of the risk_severity flag (flag: %s)',
    (dependencyFirewallRiskSeverityRule) => {
      createWrapper([], { dependencyFirewallRiskSeverityRule });
      const secondCard = findAllCards().at(1);

      expect(secondCard.props('label')).toBe('Known vulnerabilities');
    },
  );

  it('marks only malicious as recommended', () => {
    createWrapper([]);

    expect(findCard('malicious').props('recommended')).toBe(true);
    expect(findCard('vulnerability').props('recommended')).toBe(false);
    expect(findCard('license').props('recommended')).toBe(false);
  });

  it('passes each rule from the array to its matching card', () => {
    const licenseRule = { type: 'license', denied: [{ name: 'GPL-3.0' }] };
    createWrapper([licenseRule]);

    expect(findCard('license').props('rule')).toEqual(licenseRule);
    expect(findCard('malicious').props('rule')).toBeNull();
  });

  it('adds a rule when a card is toggled on', () => {
    createWrapper([]);

    findCard('license').vm.$emit('toggle', {
      checked: true,
      draftRule: { type: 'license', denied: [] },
    });

    expect(wrapper.emitted('changed')[0][0]).toEqual([{ type: 'license', denied: [] }]);
  });

  it('removes a rule when its card is toggled off', () => {
    const licenseRule = { type: 'license', denied: [] };
    const maliciousRule = { type: 'malicious', denied: [{ is_malicious: true }] };
    createWrapper([licenseRule, maliciousRule]);

    findCard('license').vm.$emit('toggle', { checked: false });

    expect(wrapper.emitted('changed')[0][0]).toEqual([maliciousRule]);
  });

  it('updates a rule in place when its card emits changed', () => {
    createWrapper([{ type: 'license', denied: [] }]);

    findCard('license').vm.$emit('changed', { type: 'license', denied: [{ name: 'MIT' }] });

    expect(wrapper.emitted('changed')[0][0]).toEqual([
      { type: 'license', denied: [{ name: 'MIT' }] },
    ]);
  });
});
