import { slashCommandContextFor } from 'ee/ai/duo_agentic_chat/context/slash_commands_context';

describe('slashCommandContextFor', () => {
  describe('a flow command', () => {
    const SCAN = {
      value: '/flow:security-scan',
      label: 'Security Scan',
      startOnly: true,
      consumerId: 42,
    };

    const contextFor = (text, slashCommands = [SCAN]) =>
      slashCommandContextFor({ text, slashCommands });

    const payloadFor = (text) => {
      const [item] = contextFor(text);

      return { ...item, content: JSON.parse(item.content) };
    };

    it('addresses the flow by consumer id, so the model never picks it', () => {
      const item = payloadFor('/flow:security-scan check the auth module');

      expect(item.category).toBe('duo_chat_command');
      expect(item.content).toEqual({
        command: 'flow',
        ai_catalog_item_consumer_id: 42,
        goal: 'check the auth module',
      });
    });

    // Rails falls back to the flow's own description only when the goal is absent.
    it.each(['/flow:security-scan', '/flow:security-scan   '])(
      'sends a null goal for %p, which carries none',
      (text) => {
        expect(payloadFor(text).content.goal).toBeNull();
      },
    );

    it('sends parsable metadata, which the service requires', () => {
      expect(JSON.parse(payloadFor('/flow:security-scan go').metadata)).toEqual({});
    });

    it('is case insensitive about the command it matches', () => {
      expect(payloadFor('/FLOW:Security-Scan go').content.goal).toBe('go');
    });

    // The builder records a command whose token appears anywhere in the text, and
    // `startOnly` is only honoured when offering one. A flow takes over the whole turn,
    // so a prompt that merely mentions one must not start it.
    it.each(['tell me what /flow:security-scan does', 'what does /flow:security-scan do?'])(
      'contributes nothing for %p, which only mentions the flow',
      (text) => {
        expect(contextFor(text)).toEqual([]);
      },
    );

    it('contributes nothing when no command was recorded', () => {
      expect(contextFor('what does this project do?', [])).toEqual([]);
    });

    // Commands that contribute nothing to the turn land in the same list.
    it('ignores a command that carries no consumer id', () => {
      expect(contextFor('/compact', [{ value: '/compact' }])).toEqual([]);
    });

    it('picks the flow out from among other commands', () => {
      const context = contextFor('/flow:security-scan go', [{ value: '/compact' }, SCAN]);

      expect(JSON.parse(context[0].content).ai_catalog_item_consumer_id).toBe(42);
    });

    it.each([undefined, {}, { text: '/flow:security-scan' }])(
      'tolerates a prompt of %p',
      (userPrompt) => {
        expect(slashCommandContextFor(userPrompt)).toEqual([]);
      },
    );
  });
});
