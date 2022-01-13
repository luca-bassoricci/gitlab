# frozen_string_literal: true

module Gitlab
  module MarketingSite
    class << self
      def default_base_url
        if ::Gitlab.dev_or_test_env?
          'https://about.staging.gitlab.com'
        else
          'https://about.gitlab.com'
        end
      end

      def base_url
        ENV.fetch('MARKETING_SITE_URL', default_base_url)
      end

      PATHS_MAP = {
        blog: 'blog',
        company_preference_center: 'company/preference-center',
        contributing: 'contributing',
        free_trial: 'free-trial',
        get_started: 'get-started',
        install: 'install',
        is_it_any_good: 'is-it-any-good',
        learn: 'learn',
        pricing: 'pricing',
        pricing_licensing_faq: 'pricing/licensing-faq',
        pricing_saas_feature_comparison: 'pricing/gitlab-com/feature-comparison',
        sales: 'sales',
        stages_devops_lifecycle: 'stages-devops-lifecycle',
        submit_feedback: 'submit-feedback',
        support: 'support'
      }.freeze

      KNOWN_PATHS = PATHS_MAP.keys.freeze

      # Matches something like:
      #   `free_trial_url(anchor: 'something')`
      # And turns it into:
      #   `'https://about.gitlab.com/free-trial/#something'`
      def method_missing(name, *args, &block)
        path_name = name.to_s.delete_suffix('_url').to_sym

        super unless KNOWN_PATHS.include?(path_name)

        path = PATHS_MAP[path_name]
        anchor = retrieve_anchor_arg(args)
        anchor_suffix = anchor ? "##{anchor}" : nil

        [base_url, path, anchor_suffix].join('/')
      end

      private

      def retrieve_anchor_arg(args)
        return unless args.last.is_a?(Hash)

        args.last[:anchor]
      end
    end
  end
end
