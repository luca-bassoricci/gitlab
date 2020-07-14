import { shallowMount } from '@vue/test-utils';
import { GlFormSelect, GlFormTextarea, GlFormInput, GlToken, GlDeprecatedButton } from '@gitlab/ui';
import {
  PERCENT_ROLLOUT_GROUP_ID,
  ROLLOUT_STRATEGY_ALL_USERS,
  ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
  ROLLOUT_STRATEGY_USER_ID,
  ROLLOUT_STRATEGY_GITLAB_USER_LIST,
} from 'ee/feature_flags/constants';
import Strategy from 'ee/feature_flags/components/strategy.vue';
import NewEnvironmentsDropdown from 'ee/feature_flags/components/new_environments_dropdown.vue';

import { userList } from '../mock_data';

describe('Feature flags strategy', () => {
  let wrapper;

  const findStrategy = () => wrapper.find('[data-testid="strategy"]');

  const factory = (
    opts = {
      propsData: {
        strategy: {},
        index: 0,
        endpoint: '',
        userLists: [userList],
      },
    },
  ) => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
    wrapper = shallowMount(Strategy, opts);
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  describe.each`
    name                                | parameter       | value    | newValue   | input
    ${ROLLOUT_STRATEGY_ALL_USERS}       | ${null}         | ${null}  | ${null}    | ${null}
    ${ROLLOUT_STRATEGY_PERCENT_ROLLOUT} | ${'percentage'} | ${'50'}  | ${'20'}    | ${GlFormInput}
    ${ROLLOUT_STRATEGY_USER_ID}         | ${'userIds'}    | ${'1,2'} | ${'1,2,3'} | ${GlFormTextarea}
  `('with strategy $name', ({ name, parameter, value, newValue, input }) => {
    let propsData;
    let strategy;
    beforeEach(() => {
      const parameters = {};
      if (parameter !== null) {
        parameters[parameter] = value;
      }
      strategy = { name, parameters };
      propsData = { strategy, index: 0, endpoint: '' };
      factory({ propsData });
    });

    it('should set the select to match the strategy name', () => {
      expect(wrapper.find(GlFormSelect).attributes('value')).toBe(name);
    });

    it('should not show inputs for other parameters', () => {
      [GlFormTextarea, GlFormInput, GlFormSelect]
        .filter(component => component !== input)
        .map(component => findStrategy().findAll(component))
        .forEach(inputWrapper => expect(inputWrapper).toHaveLength(0));
    });

    if (parameter !== null) {
      it(`should show the input for ${parameter} with the correct value`, () => {
        const inputWrapper = findStrategy().find(input);
        expect(inputWrapper.exists()).toBe(true);
        expect(inputWrapper.attributes('value')).toBe(value);
      });

      it(`should emit a change event when altering ${parameter}`, () => {
        const inputWrapper = findStrategy().find(input);
        inputWrapper.vm.$emit('input', newValue);
        expect(wrapper.emitted('change')).toEqual([
          [{ name, parameters: expect.objectContaining({ [parameter]: newValue }), scopes: [] }],
        ]);
      });
    }
  });
  describe('with strategy gitlabUserList', () => {
    let propsData;
    let strategy;
    beforeEach(() => {
      strategy = { name: ROLLOUT_STRATEGY_GITLAB_USER_LIST, userListId: '2', parameters: {} };
      propsData = { strategy, index: 0, endpoint: '', userLists: [userList] };
      factory({ propsData });
    });

    it('should set the select to match the strategy name', () => {
      expect(wrapper.find(GlFormSelect).attributes('value')).toBe(
        ROLLOUT_STRATEGY_GITLAB_USER_LIST,
      );
    });

    it('should not show inputs for other parameters', () => {
      expect(findStrategy().contains(GlFormTextarea)).toBe(false);
      expect(findStrategy().contains(GlFormInput)).toBe(false);
    });

    it('should show the input for userListId with the correct value', () => {
      const inputWrapper = findStrategy().find(GlFormSelect);
      expect(inputWrapper.exists()).toBe(true);
      expect(inputWrapper.attributes('value')).toBe('2');
    });

    it('should emit a change event when altering the userListId', () => {
      const inputWrapper = findStrategy().find(GlFormSelect);
      inputWrapper.vm.$emit('input', '3');
      inputWrapper.vm.$emit('change', '3');
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted('change')).toEqual([
          [
            {
              name: ROLLOUT_STRATEGY_GITLAB_USER_LIST,
              userListId: '3',
              scopes: [],
              parameters: {},
            },
          ],
        ]);
      });
    });
  });

  describe('with a strategy', () => {
    describe('with scopes defined', () => {
      let strategy;

      beforeEach(() => {
        strategy = {
          name: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
          parameters: { percentage: '50' },
          scopes: [{ environmentScope: '*' }],
        };
        const propsData = { strategy, index: 0, endpoint: '' };
        factory({ propsData });
      });

      it('should change the parameters if a different strategy is chosen', () => {
        const select = wrapper.find(GlFormSelect);
        select.vm.$emit('input', ROLLOUT_STRATEGY_ALL_USERS);
        select.vm.$emit('change', ROLLOUT_STRATEGY_ALL_USERS);
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.find(GlFormInput).exists()).toBe(false);
          expect(wrapper.emitted('change')).toEqual([
            [
              {
                name: ROLLOUT_STRATEGY_ALL_USERS,
                parameters: {},
                scopes: [{ environmentScope: '*' }],
              },
            ],
          ]);
        });
      });

      it('should display selected scopes', () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        dropdown.vm.$emit('add', 'production');
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.findAll(GlToken)).toHaveLength(1);
          expect(wrapper.find(GlToken).text()).toBe('production');
        });
      });

      it('should display all selected scopes', () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        dropdown.vm.$emit('add', 'production');
        dropdown.vm.$emit('add', 'staging');
        return wrapper.vm.$nextTick().then(() => {
          const tokens = wrapper.findAll(GlToken);
          expect(tokens).toHaveLength(2);
          expect(tokens.at(0).text()).toBe('production');
          expect(tokens.at(1).text()).toBe('staging');
        });
      });

      it('should emit selected scopes', () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        dropdown.vm.$emit('add', 'production');
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emitted('change')).toEqual([
            [
              {
                name: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
                parameters: { percentage: '50', groupId: PERCENT_ROLLOUT_GROUP_ID },
                scopes: [
                  { environmentScope: '*', shouldBeDestroyed: true },
                  { environmentScope: 'production' },
                ],
              },
            ],
          ]);
        });
      });

      it('should emit a delete if the delete button is clicked', () => {
        wrapper.find(GlDeprecatedButton).vm.$emit('click');
        expect(wrapper.emitted('delete')).toEqual([[]]);
      });
    });

    describe('with a production scope with an id defined', () => {
      beforeEach(() => {
        const strategy = {
          name: ROLLOUT_STRATEGY_ALL_USERS,
          parameters: {},
          scopes: [{ id: 1, environmentScope: 'production' }],
        };
        const propsData = { strategy, index: 0, endpoint: '' };
        factory({ propsData });
      });

      it('displays all environments text when removing the scope, adding a new scope, and then removing the new scope', async () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        wrapper.find(GlToken).vm.$emit('close');
        await wrapper.vm.$nextTick();
        dropdown.vm.$emit('add', 'staging');
        await wrapper.vm.$nextTick();
        wrapper.find(GlToken).vm.$emit('close');
        await wrapper.vm.$nextTick();

        expect(wrapper.text()).toMatch(/All environments/);
      });
    });

    describe('without scopes defined', () => {
      beforeEach(() => {
        const strategy = {
          name: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
          parameters: { percentage: '50' },
          scopes: [],
        };
        const propsData = { strategy, index: 0, endpoint: '' };
        factory({ propsData });
      });

      it('should display selected scopes', () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        dropdown.vm.$emit('add', 'production');
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.findAll(GlToken)).toHaveLength(1);
          expect(wrapper.find(GlToken).text()).toBe('production');
        });
      });

      it('should display all selected scopes', () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        dropdown.vm.$emit('add', 'production');
        dropdown.vm.$emit('add', 'staging');
        return wrapper.vm.$nextTick().then(() => {
          const tokens = wrapper.findAll(GlToken);
          expect(tokens).toHaveLength(2);
          expect(tokens.at(0).text()).toBe('production');
          expect(tokens.at(1).text()).toBe('staging');
        });
      });

      it('should emit selected scopes', () => {
        const dropdown = wrapper.find(NewEnvironmentsDropdown);
        dropdown.vm.$emit('add', 'production');
        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emitted('change')).toEqual([
            [
              {
                name: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
                parameters: { percentage: '50', groupId: PERCENT_ROLLOUT_GROUP_ID },
                scopes: [{ environmentScope: 'production' }],
              },
            ],
          ]);
        });
      });

      it('displays the proper text', () => {
        expect(wrapper.text()).toMatch('No environments');
      });
    });
  });

  describe('removeScope', () => {
    const setup = scopes => {
      factory({
        propsData: {
          strategy: {
            name: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
            parameters: { percentage: '50' },
            scopes,
          },
          index: 0,
          endpoint: '',
        },
      });
    };

    it('sets shouldBeDestroyed to true for a scope with an id', () => {
      setup([{ id: 1, environmentScope: 'production' }, { id: 2, environmentScope: 'staging' }]);
      const scope = wrapper.props('strategy').scopes[0];

      wrapper.vm.removeScope(scope);

      expect(wrapper.vm.environments).toEqual([
        { id: 1, environmentScope: 'production', shouldBeDestroyed: true },
        { id: 2, environmentScope: 'staging' },
      ]);
    });

    it('removes the scope for a scope without an id', () => {
      setup([{ environmentScope: 'production' }, { id: 2, environmentScope: 'staging' }]);
      const scope = wrapper.props('strategy').scopes[0];

      wrapper.vm.removeScope(scope);

      expect(wrapper.vm.environments).toEqual([{ id: 2, environmentScope: 'staging' }]);
    });

    it('adds a new all environments scope when the removed scope has an id and is the last one', () => {
      setup([{ id: 1, environmentScope: 'production' }]);
      const scope = wrapper.props('strategy').scopes[0];

      wrapper.vm.removeScope(scope);

      expect(wrapper.vm.environments).toEqual([
        { id: 1, environmentScope: 'production', shouldBeDestroyed: true },
        { environmentScope: '*' },
      ]);
    });

    it('adds a new all environments scope when the removed scope does not have an id and is the last one', () => {
      setup([{ environmentScope: 'production' }]);
      const scope = wrapper.props('strategy').scopes[0];

      wrapper.vm.removeScope(scope);

      expect(wrapper.vm.environments).toEqual([{ environmentScope: '*' }]);
    });

    it('adds a new all environments scope when the removed scope is the last one and there are two scopes with an id', () => {
      setup([
        { id: 1, environmentScope: 'production', shouldBeDestroyed: true },
        { id: 2, environmentScope: 'staging' },
      ]);
      const scope = wrapper.props('strategy').scopes[1];

      wrapper.vm.removeScope(scope);

      expect(wrapper.vm.environments).toEqual([
        { id: 1, environmentScope: 'production', shouldBeDestroyed: true },
        { id: 2, environmentScope: 'staging', shouldBeDestroyed: true },
        { environmentScope: '*' },
      ]);
    });

    it('changes shouldBeDestroyed to false if the all environments scope is the last scope', () => {
      setup([
        { id: 1, environmentScope: '*', shouldBeDestroyed: true },
        { environmentScope: 'production' },
      ]);
      const scope = wrapper.props('strategy').scopes[1];

      wrapper.vm.removeScope(scope);

      expect(wrapper.vm.environments).toEqual([
        { id: 1, environmentScope: '*', shouldBeDestroyed: false },
      ]);
    });

    it('leaves shouldBeDestroyed true if the all environments scope is not the last scope', () => {
      setup([
        { id: 1, environmentScope: '*', shouldBeDestroyed: true },
        { environmentScope: 'production' },
        { environmentScope: 'staging' },
      ]);
      const scope = wrapper.props('strategy').scopes[1];

      wrapper.vm.removeScope(scope);

      expect(wrapper.vm.environments).toEqual([
        { id: 1, environmentScope: '*', shouldBeDestroyed: true },
        { environmentScope: 'staging' },
      ]);
    });
  });

  describe('appliesToAllEnvironments', () => {
    const setup = scopes => {
      factory({
        propsData: {
          strategy: {
            name: ROLLOUT_STRATEGY_ALL_USERS,
            parameters: {},
            scopes,
          },
          index: 0,
          endpoint: '',
        },
      });
    };

    it('returns true when there is an all environments scope', () => {
      setup([{ id: 1, environmentScope: '*' }]);

      expect(wrapper.vm.appliesToAllEnvironments).toBe(true);
    });

    it('returns false when there are no scopes', () => {
      setup([]);

      expect(wrapper.vm.appliesToAllEnvironments).toBe(false);
    });
  });
});
