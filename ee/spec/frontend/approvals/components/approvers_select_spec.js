import { GlDropdown, GlDropdownItem, GlSearchBoxByType } from '@gitlab/ui';
import { shallowMount, mount } from '@vue/test-utils';
import Api from 'ee/api';
import ApproversSelect from 'ee/approvals/components/approvers_select.vue';
import { TEST_HOST } from 'helpers/test_constants';
import waitForPromises from 'helpers/wait_for_promises';
import { NAMESPACE_TYPES } from 'ee/security_orchestration/constants';

const TEST_PROJECT_ID = '17';
const TEST_GROUP_AVATAR = `${TEST_HOST}/group-avatar.png`;
const TEST_USER_AVATAR = `${TEST_HOST}/user-avatar.png`;
const TEST_GROUPS = [
  { id: 1, full_name: 'GitLab Org', full_path: 'gitlab/org', avatar_url: null },
  {
    id: 2,
    full_name: 'Lorem Ipsum',
    full_path: 'lorem-ipsum',
    avatar_url: TEST_GROUP_AVATAR,
  },
];
const TEST_USERS = [
  { id: 1, name: 'Dolar', username: 'dolar', avatar_url: TEST_USER_AVATAR },
  { id: 3, name: 'Sit', username: 'sit', avatar_url: TEST_USER_AVATAR },
];

const TERM = 'lorem';

describe('Approvers Selector', () => {
  let wrapper;

  const findDropdown = () => wrapper.findComponent(GlDropdown);
  const findDropdownItems = () => wrapper.findAllComponents(GlDropdownItem);
  const findSearch = () => wrapper.findComponent(GlSearchBoxByType);

  const createComponent = (
    props = {},
    permitAllSharedGroupsForApproval = false,
    mountFn = shallowMount,
  ) => {
    wrapper = mountFn(ApproversSelect, {
      propsData: {
        namespaceId: TEST_PROJECT_ID,
        ...props,
      },
      provide: {
        glFeatures: {
          permitAllSharedGroupsForApproval,
        },
      },
    });
  };

  beforeEach(() => {
    jest.spyOn(Api, 'groups').mockResolvedValue(TEST_GROUPS);
    jest.spyOn(Api, 'projectGroups').mockResolvedValue(TEST_GROUPS);
    jest.spyOn(Api, 'projectUsers').mockReturnValue(Promise.resolve(TEST_USERS));
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Initialization', () => {
    it('renders the dropdown', async () => {
      createComponent();
      await waitForPromises();

      expect(findDropdown().exists()).toBe(true);
    });

    it('renders dropdown with invalid class if is invalid', async () => {
      createComponent({ isInvalid: true });
      await waitForPromises();

      expect(findDropdown().classes('is-invalid')).toBe(true);
    });
  });

  describe('Using search', () => {
    it('queries groups and users', async () => {
      createComponent();
      await waitForPromises();

      const groupDropdownItems = findDropdownItems().filter((el) =>
        el.find('div.group-name').exists(),
      );
      const usersDropdownItems = findDropdownItems().filter((el) =>
        el.find('div.user-name').exists(),
      );

      expect(groupDropdownItems).toHaveLength(TEST_GROUPS.length);
      expect(usersDropdownItems).toHaveLength(TEST_USERS.length);
    });

    describe('with permitAllSharedGroupsForApproval', () => {
      beforeEach(async () => {
        createComponent({}, true);

        await waitForPromises();
      });

      it('fetches all available groups including non-visible shared groups', async () => {
        expect(Api.projectGroups).toHaveBeenCalledWith(TEST_PROJECT_ID, {
          skip_groups: [],
          with_shared: true,
          shared_visible_only: false,
          shared_min_access_level: 30,
        });
      });
    });

    describe.each`
      namespaceType              | api               | mockedValue             | expectedParams
      ${NAMESPACE_TYPES.PROJECT} | ${'projectUsers'} | ${TEST_USERS}           | ${[TEST_PROJECT_ID, TERM, { skip_users: [] }]}
      ${NAMESPACE_TYPES.GROUP}   | ${'groupMembers'} | ${{ data: TEST_USERS }} | ${[TEST_PROJECT_ID, { query: TERM, skip_users: [] }]}
    `(
      'with namespaceType: $namespaceType and search term',
      ({ namespaceType, api, mockedValue, expectedParams }) => {
        beforeEach(async () => {
          jest.spyOn(Api, api).mockReturnValue(Promise.resolve(mockedValue));

          createComponent({ namespaceType }, false, mount);
          await waitForPromises();

          findSearch().vm.$emit('input', TERM);
          await waitForPromises();
        });

        it('fetches all available groups', () => {
          expect(Api.groups).toHaveBeenCalledWith(TERM, {
            skip_groups: [],
            all_available: true,
          });
        });

        it('fetches users', () => {
          expect(Api[api]).toHaveBeenCalledWith(...expectedParams);
        });
      },
    );

    describe('with empty seach term and skips', () => {
      const skipGroupIds = [7, 8];
      const skipUserIds = [9, 10];

      beforeEach(async () => {
        createComponent({
          skipGroupIds,
          skipUserIds,
        });
        await waitForPromises();
      });

      it('skips groups and does not fetch all available', () => {
        expect(Api.groups).toHaveBeenCalledWith('', {
          skip_groups: skipGroupIds,
          all_available: false,
        });
      });

      it('skips users', () => {
        expect(Api.projectUsers).toHaveBeenCalledWith(TEST_PROJECT_ID, '', {
          skip_users: skipUserIds,
        });
      });
    });

    it('emits input when data changes', async () => {
      // const expectedFinal = [
      //   { ...TEST_USERS[0], type: TYPE_USER },
      //   { ...TEST_GROUPS[0], type: TYPE_GROUP },
      // ];
      // const expected = expectedFinal.map((x, idx) => [expectedFinal.slice(0, idx + 1)]);
      createComponent();
      await waitForPromises();

      findDropdownItems().at(0).vm.$emit('click');
      await waitForPromises();

      // TODO: Verify this select2 behavior
      // expect(wrapper.emitted().input).toEqual(expected);
      expect(wrapper.emitted().input).toHaveLength(1);
    });
  });
});
