import { mount } from '@vue/test-utils';
import { createAlert } from '~/alert';
import 'jh/vue_overrides';

jest.mock('~/alert');

const contentValidationMessage =
  "Your content couldn't be submitted because it violated the rules. If you believe this was a miscalculation, please email usersupport@gitlab.cn to appeal. We will process your appeal within 24 hours (working days) and send the result to your registered email address, please pay attention to it. Thank you for your understanding and support.";

describe('JH note error overrides', () => {
  let wrapper;
  let fallback;

  describe.each([
    ['CommentForm', 'handleSaveError'],
    ['NoteableNote', 'handleUpdateError'],
    ['NoteableDiscussion', 'handleSaveError'],
  ])('%s', (name, method) => {
    const createComponent = (response, { multiple = false } = {}) => {
      const error = name === 'CommentForm' ? response : { response };
      fallback = jest.fn(function handleError() {
        this.errors = ['Original error handler'];
      });

      const component = {
        name,
        data() {
          return { errors: [] };
        },
        methods: {
          [method]: fallback,
          submit() {
            const callback = this[method];
            callback(error);
          },
        },
        render(h) {
          return h('div', [
            h('button', { on: { click: this.submit } }, 'Save'),
            ...this.errors.map((message) => h('p', { key: message }, message)),
          ]);
        },
      };

      wrapper = mount(
        multiple
          ? { render: (h) => h('div', [h(component, { key: 1 }), h(component, { key: 2 })]) }
          : component,
      );
    };

    describe('when content validation rejects the note', () => {
      beforeEach(() => {
        createComponent({ status: 422, data: { content_invalid: true, errors: 'Rejected' } });
      });

      it('shows the JH appeal message', async () => {
        await wrapper.find('button').trigger('click');

        if (name === 'CommentForm') {
          expect(wrapper.text()).toContain(contentValidationMessage);
          expect(createAlert).not.toHaveBeenCalled();
        } else {
          expect(createAlert).toHaveBeenCalledWith({
            message: contentValidationMessage,
            parent: wrapper.element,
          });
        }
        expect(fallback).not.toHaveBeenCalled();
      });
    });

    describe('when the request fails for another reason', () => {
      const response = { status: 500, data: { errors: 'Server error' } };

      beforeEach(() => {
        createComponent(response);
      });

      it('calls the original bound handler once with the response', async () => {
        await wrapper.find('button').trigger('click');

        expect(fallback).toHaveBeenCalledTimes(1);
        expect(fallback).toHaveBeenCalledWith(name === 'CommentForm' ? response : { response });
        expect(wrapper.text()).toContain('Original error handler');
        expect(createAlert).not.toHaveBeenCalled();
      });
    });

    describe('when multiple instances are mounted', () => {
      beforeEach(() => {
        createComponent({ status: 500, data: { errors: 'Server error' } }, { multiple: true });
      });

      it('keeps each error handler bound to its own instance', async () => {
        const buttons = wrapper.findAll('button');
        await buttons.at(0).trigger('click');

        expect(wrapper.findAll('p')).toHaveLength(1);
        expect(fallback).toHaveBeenCalledTimes(1);

        await buttons.at(1).trigger('click');

        expect(wrapper.findAll('p')).toHaveLength(2);
        expect(fallback).toHaveBeenCalledTimes(2);
        expect(createAlert).not.toHaveBeenCalled();
      });
    });
  });
});
