import { shallowMount } from '@vue/test-utils';
import { stubExperiments } from 'helpers/experimentation_helper';
import { mockTracking, triggerEvent, unmockTracking } from 'helpers/tracking_helper';
import eventHub from '~/invite_members/event_hub';
import LearnGitlabSectionLink from '~/pages/projects/learn_gitlab/components/learn_gitlab_section_link.vue';

const defaultAction = 'gitWrite';
const defaultProps = {
  title: 'Create Repository',
  description: 'Some description',
  url: 'https://example.com',
  completed: false,
};

describe('Learn GitLab Section Link', () => {
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const createWrapper = (action = defaultAction, props = {}) => {
    wrapper = shallowMount(LearnGitlabSectionLink, {
      propsData: { action, value: { ...defaultProps, ...props } },
    });
  };

  const openInviteMembesrModalLink = () =>
    wrapper.find('[data-testid="invite-for-help-continuous-onboarding-experiment-link"]');

  it('renders no icon when not completed', () => {
    createWrapper(undefined, { completed: false });

    expect(wrapper.find('[data-testid="completed-icon"]').exists()).toBe(false);
  });

  it('renders the completion icon when completed', () => {
    createWrapper(undefined, { completed: true });

    expect(wrapper.find('[data-testid="completed-icon"]').exists()).toBe(true);
  });

  it('renders no trial only when it is not required', () => {
    createWrapper();

    expect(wrapper.find('[data-testid="trial-only"]').exists()).toBe(false);
  });

  it('renders trial only when trial is required', () => {
    createWrapper('codeOwnersEnabled');

    expect(wrapper.find('[data-testid="trial-only"]').exists()).toBe(true);
  });

  describe('rendering a link to open the invite_members modal instead of a regular link', () => {
    it.each`
      action           | experimentVariant | showModal
      ${'userAdded'}   | ${'candidate'}    | ${true}
      ${'userAdded'}   | ${'control'}      | ${false}
      ${defaultAction} | ${'candidate'}    | ${false}
      ${defaultAction} | ${'control'}      | ${false}
    `(
      'when the invite_for_help_continuous_onboarding experiment has variant: $experimentVariant and action is $action, the modal link is shown: $showModal',
      ({ action, experimentVariant, showModal }) => {
        stubExperiments({ invite_for_help_continuous_onboarding: experimentVariant });
        createWrapper(action);

        expect(openInviteMembesrModalLink().exists()).toBe(showModal);
      },
    );
  });

  describe('clicking the link to open the invite_members modal', () => {
    beforeEach(() => {
      jest.spyOn(eventHub, '$emit').mockImplementation();

      stubExperiments({ invite_for_help_continuous_onboarding: 'candidate' });
      createWrapper('userAdded');
    });

    it('calls the eventHub', () => {
      openInviteMembesrModalLink().vm.$emit('click');

      expect(eventHub.$emit).toHaveBeenCalledWith('openModal', {
        inviteeType: 'members',
        source: 'learn_gitlab',
        tasksToBeDoneEnabled: true,
      });
    });

    it('tracks the click', async () => {
      const trackingSpy = mockTracking('_category_', wrapper.element, jest.spyOn);

      triggerEvent(openInviteMembesrModalLink().element);

      expect(trackingSpy).toHaveBeenCalledWith('_category_', 'click_link', {
        label: 'Invite your colleagues',
        property: 'Growth::Activation::Experiment::InviteForHelpContinuousOnboarding',
      });

      unmockTracking();
    });
  });
});
