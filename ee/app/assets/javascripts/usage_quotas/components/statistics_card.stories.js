import { GlCard, GlButton, GlLink, GlIcon } from '@gitlab/ui';
import StatisticsCard from './statistics_card.vue';

export default {
  component: StatisticsCard,
  title: 'usage_quotas/components/statistics_card',
};

const Template = (_, { argTypes }) => ({
  components: { StatisticsCard, GlCard },
  props: Object.keys(argTypes),
  template: `<gl-card class="gl-w-half">
      <statistics-card v-bind="$props">
        <div class="gl-font-size-28 gl-font-weight-bold">100 MB / 1000 GiB</div>
      </statistics-card>
     </gl-card>`,
});
export const Default = Template.bind({});

/* eslint-disable @gitlab/require-i18n-strings */
Default.args = {
  description: 'Additional minutes used',
  helpLink: 'dummy.com/link',
  percentage: 84,
  purchaseButtonLink: 'purchase.com/test',
  purchaseButtonText: 'Purchase additional storage',
};

export const WithSlots = (_, { argTypes }) => ({
  components: { StatisticsCard, GlCard },
  props: Object.keys(argTypes),
  template: `<gl-card class="gl-w-half">
      <statistics-card v-bind="$props">
        <div class="gl-font-size-28 gl-font-weight-bold">100 MB / 1000 GiB</div>
        <template #top-left>
          I'm in the top left!
        </template>
        <template #footer>
          I'm in the footer
        </template>
      </statistics-card>
     </gl-card>`,
});

export const Customized = (_, { argTypes }) => ({
  components: { StatisticsCard, GlButton, GlLink, GlIcon, GlCard },
  props: Object.keys(argTypes),
  template: `<gl-card class="gl-w-half">
      <statistics-card v-bind="$props">
        <div class="gl-border-b-1 gl-border-b-solid gl-border-b-gray-100 gl-flex-grow-1 gl-mb-3 gl-display-flex gl-flex-row">
          <p class="gl-font-size-h-display gl-font-weight-bold gl-flex-grow-1 gl-mb-3">
            100 / 1000
            <gl-link
              href="https://about.gitlab.com/handbook"
              target="_blank"
              rel="noopener noreferrer nofollow"
              class="gl-ml-2 gl-relative gl-bottom-2">
              <gl-icon name="question-o" />
            </gl-link>
          </p>
          <p class="gl-font-size-h-display gl-font-weight-bold gl-flex-grow-1 gl-mb-3">
            100 / 1000
            <gl-link
              href="https://about.gitlab.com/handbook"
              target="_blank"
              rel="noopener noreferrer nofollow"
              class="gl-ml-2 gl-relative gl-bottom-2">
              <gl-icon name="question-o" />
            </gl-link>
          </p>
        </div>
        <template #top-left>
        </template>
        <template #footer>
          <div class="gl-display-flex gl-flex-direction-row-reverse">
            <gl-button href="https://gitlab.com" category="primary" variant="confirm" class="gl-ml-2">Add seats</gl-button>
            <gl-button href="https://gitlab.com" category="secondary" variant="confirm">Refresh seats</gl-button>
          </div>
        </template>
      </statistics-card>
     </gl-card>
  `,
});
