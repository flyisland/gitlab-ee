import { UserPromptBuilder } from 'ee/ai/duo_agentic_chat/services/user_prompt';
import { MAX_PROMPT_LENGTH } from 'ee/ai/tanuki_bot/constants';

const COMPACT = { value: '/compact', description: 'Compact' };
const NEW = { value: '/new', description: 'New' };
const CATALOGUE = [COMPACT, NEW];

const builderWith = (text, catalogue = CATALOGUE) =>
  UserPromptBuilder.empty().withCatalogue(catalogue).withText(text);

describe('UserPromptBuilder', () => {
  describe('empty', () => {
    it('builds an empty prompt', () => {
      expect(UserPromptBuilder.empty().build()).toEqual({
        text: '',
        slashCommands: [],
        attachments: [],
      });
    });
  });

  describe('withText', () => {
    it('does not mutate the builder it came from', () => {
      const original = UserPromptBuilder.empty();

      original.withText('hello');

      expect(original.text).toBe('');
    });

    it('trims the text when building', () => {
      expect(builderWith('  hello  ').build().text).toBe('hello');
    });
  });

  describe('slashCommands', () => {
    it('records a command the user typed by hand', () => {
      expect(builderWith('/compact').build().slashCommands).toEqual([COMPACT]);
    });

    it('drops a command once its token is edited away', () => {
      const draft = builderWith('/compact please').withText('please');

      expect(draft.build().slashCommands).toEqual([]);
    });

    it('keeps a command while text around it changes', () => {
      const draft = builderWith('/compact').withText('/compact everything');

      expect(draft.build().slashCommands).toEqual([COMPACT]);
    });

    it('orders the commands by where they appear in the text', () => {
      const commands = builderWith('/new then /compact').build().slashCommands;

      expect(commands).toEqual([NEW, COMPACT]);
    });

    // The menu closes on `/Compact ` because it decides a typed token is a command
    // case-insensitively, so the payload has to agree or the two disagree about
    // whether a command was used at all.
    it('matches a token the user typed in a different case', () => {
      expect(builderWith('/Compact').build().slashCommands).toEqual([COMPACT]);
    });

    it('does not match a token that is only a prefix of a longer word', () => {
      expect(builderWith('/compacting').build().slashCommands).toEqual([]);
    });

    it('does not match a token inside a URL', () => {
      expect(builderWith('https://example.com/new').build().slashCommands).toEqual([]);
    });

    it('finds a command nested in a group', () => {
      const grouped = [{ label: 'Chat', items: [COMPACT] }];

      expect(builderWith('/compact', grouped).build().slashCommands).toEqual([COMPACT]);
    });

    it('picks up a token typed before the catalogue resolved', () => {
      const draft = UserPromptBuilder.empty().withText('/compact').withCatalogue(CATALOGUE);

      expect(draft.build().slashCommands).toEqual([COMPACT]);
    });

    it('is empty while the catalogue is still unresolved', () => {
      expect(UserPromptBuilder.empty().withText('/compact').build().slashCommands).toEqual([]);
    });

    // A context switch reloads the catalogue, and the reloaded one need not still
    // offer a command the user has already typed. The token is in the text, so the
    // command is still part of the prompt.
    it('keeps a recorded command the reloaded catalogue no longer offers', () => {
      const draft = builderWith('/compact').withCatalogue([]);

      expect(draft.build().slashCommands).toEqual([COMPACT]);
    });

    it('still drops that command once its token leaves the text', () => {
      const draft = builderWith('/compact').withCatalogue([]).withText('never mind');

      expect(draft.build().slashCommands).toEqual([]);
    });

    it('preserves a record already held for a token across a text edit', () => {
      // Stands in for a command carrying something the catalogue cannot supply, such
      // as a selected param.
      const withParam = { ...COMPACT, param: { id: 'gid://gitlab/Label/1' } };
      const draft = builderWith('/compact', [withParam])
        .withCatalogue(CATALOGUE)
        .withText('/compact everything');

      expect(draft.build().slashCommands).toEqual([withParam]);
    });
  });

  describe('withSlashCommand', () => {
    it('replaces only the matched token', () => {
      const draft = builderWith('tell me /comp about it').withSlashCommand(COMPACT, {
        triggerIndex: 8,
        token: '/comp',
      });

      expect(draft.text).toBe('tell me /compact about it');
    });

    it('adds a separator when the command would run into what follows', () => {
      const draft = builderWith('/comp').withSlashCommand(COMPACT, {
        triggerIndex: 0,
        token: '/comp',
      });

      expect(draft.text).toBe('/compact ');
    });

    it('records the command it inserted', () => {
      const draft = builderWith('/comp').withSlashCommand(COMPACT, {
        triggerIndex: 0,
        token: '/comp',
      });

      expect(draft.build().slashCommands).toEqual([COMPACT]);
    });
  });

  describe('attachments', () => {
    it('adds and removes by id', () => {
      const draft = UserPromptBuilder.empty()
        .withAttachment({ id: 'a1' })
        .withAttachment({ id: 'a2' })
        .withoutAttachment('a1');

      expect(draft.build().attachments).toEqual([{ id: 'a2' }]);
    });
  });

  describe('cleared', () => {
    it('empties the draft but keeps the catalogue', () => {
      const draft = builderWith('/compact').withAttachment({ id: 'a1' }).cleared();

      expect(draft.build()).toEqual({ text: '', slashCommands: [], attachments: [] });
      expect(draft.withText('/compact').build().slashCommands).toEqual([COMPACT]);
    });
  });

  describe('isTextEmpty', () => {
    it.each([
      ['', true],
      ['   ', true],
      ['hello', false],
    ])('is %p for %p', (text, expected) => {
      expect(builderWith(text).isTextEmpty).toBe(expected);
    });
  });

  describe('isTextWithinLengthLimit', () => {
    it('allows text at the limit', () => {
      expect(builderWith('a'.repeat(MAX_PROMPT_LENGTH)).isTextWithinLengthLimit).toBe(true);
    });

    it('rejects text past the limit', () => {
      expect(builderWith('a'.repeat(MAX_PROMPT_LENGTH + 1)).isTextWithinLengthLimit).toBe(false);
    });
  });
});
