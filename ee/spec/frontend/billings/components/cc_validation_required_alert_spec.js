import { GlAlert, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import CreditCardValidationRequiredAlert from 'ee/billings/components/cc_validation_required_alert.vue';
import { TEST_HOST } from 'helpers/test_constants';

describe('CreditCardValidationRequiredAlert', () => {
  let wrapper;

  const createComponent = (data = {}) => {
    return shallowMount(CreditCardValidationRequiredAlert, {
      stubs: {
        GlSprintf,
      },
      data() {
        return data;
      },
    });
  };

  const findGlAlert = () => wrapper.findComponent(GlAlert);

  beforeEach(() => {
    window.gon = {
      subscriptions_url: TEST_HOST,
      payment_form_url: TEST_HOST,
    };

    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders title', () => {
    expect(findGlAlert().attributes('title')).toBe('User validation required');
  });

  it('renders description', () => {
    expect(findGlAlert().text()).toContain('To use free pipeline minutes');
  });

  it('renders danger alert', () => {
    expect(findGlAlert().attributes('variant')).toBe('danger');
  });

  it('renders the success alert instead of danger', () => {
    wrapper = createComponent({ shouldRenderSuccess: true });

    expect(findGlAlert().attributes('variant')).toBe('success');
  });
});
