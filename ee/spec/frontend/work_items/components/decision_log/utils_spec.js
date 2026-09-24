import { decisionSource } from 'ee/work_items/components/decision_log/utils';
import {
  DECISION_SOURCE_DUO_FLOW,
  DECISION_SOURCE_MANUAL,
  DECISION_SOURCE_THREAD_RESOLUTION,
} from 'ee/work_items/components/decision_log/constants';

const discussionId = `gid://gitlab/Discussion/${'a'.repeat(40)}`;
const sourceLink = 'https://gitlab.example.com/acme/web/-/work_items/7#note_1';

describe('decisionSource', () => {
  describe('when the decision carries a source link', () => {
    it('reads it as recorded manually', () => {
      expect(decisionSource({ sourceLink, discussionId: null })).toBe(DECISION_SOURCE_MANUAL);
    });

    // Only the form sets a source link, so it settles the question on its own.
    it('reads it as recorded manually even with a discussion', () => {
      expect(decisionSource({ sourceLink, discussionId })).toBe(DECISION_SOURCE_MANUAL);
    });
  });

  describe('when the decision carries a discussion', () => {
    it('reads it as marked from a thread', () => {
      expect(decisionSource({ sourceLink: null, discussionId })).toBe(
        DECISION_SOURCE_THREAD_RESOLUTION,
      );
    });
  });

  describe('when the decision carries neither mark', () => {
    it('reads it as Duo work, because nothing else writes a decision', () => {
      expect(decisionSource({ sourceLink: null, discussionId: null })).toBe(
        DECISION_SOURCE_DUO_FLOW,
      );
    });
  });
});
