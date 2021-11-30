# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a CI/CD Processable (a job)
        #
        module Processable
          extend ActiveSupport::Concern

          include ::Gitlab::Config::Entry::Configurable
          include ::Gitlab::Config::Entry::Attributable
          include ::Gitlab::Config::Entry::Inheritable
          include ::Gitlab::Utils::StrongMemoize

          PROCESSABLE_ALLOWED_KEYS = %i[extends stage only except rules variables
                                        inherit allow_failure when needs resource_group].freeze
          MAX_NESTING_LEVEL = 10

          included do
            validations do
              validates :config, presence: true
              validates :name, presence: true
              validates :name, type: Symbol
              validates :name, length: { maximum: 255 }, if: -> { ::Feature.enabled?(:ci_validate_job_length, default_enabled: :yaml) }

              validates :config, disallowed_keys: {
                  in: %i[only except when start_in],
                  message: 'key may not be used with `rules`'
                },
                if: :has_rules?

              with_options allow_nil: true do
                validates :extends, array_of_strings_or_string: true
                validates :rules, nested_array_of_hashes_or_arrays: { max_level: MAX_NESTING_LEVEL }
                validates :resource_group, type: String
              end

              validate(on: :composed) { validate_against_warnings }
            end

            entry :stage, Entry::Stage,
              description: 'Pipeline stage this job will be executed into.',
              inherit: false

            entry :only, ::Gitlab::Ci::Config::Entry::Policy,
              description: 'Refs policy this job will be executed for.',
              default: ::Gitlab::Ci::Config::Entry::Policy::DEFAULT_ONLY,
              inherit: false

            entry :except, ::Gitlab::Ci::Config::Entry::Policy,
              description: 'Refs policy this job will be executed for.',
              inherit: false

            entry :rules, ::Gitlab::Ci::Config::Entry::Rules,
              description: 'List of evaluable Rules to determine job inclusion.',
              inherit: false,
              metadata: {
                allowed_when: %w[on_success on_failure always never manual delayed].freeze
              }

            entry :variables, ::Gitlab::Ci::Config::Entry::Variables,
              description: 'Environment variables available for this job.',
              inherit: false

            entry :inherit, ::Gitlab::Ci::Config::Entry::Inherit,
              description: 'Indicates whether to inherit defaults or not.',
              inherit: false,
              default: {}

            attributes :extends, :rules, :resource_group
          end

          def compose!(deps = nil)
            super do
              # If workflow:rules: or rules: are used
              # they are considered not compatible
              # with `only/except` defaults
              #
              # Context: https://gitlab.com/gitlab-org/gitlab/merge_requests/21742
              if has_rules? || has_workflow_rules?
                # Remove only/except defaults
                # defaults are not considered as defined
                @entries.delete(:only) unless only_defined? # rubocop:disable Gitlab/ModuleWithInstanceVariables
                @entries.delete(:except) unless except_defined? # rubocop:disable Gitlab/ModuleWithInstanceVariables
              end

              yield if block_given?
            end
          end

          def validate_against_warnings
            # If rules are valid format and workflow rules are not specified
            return if has_workflow_rules?
            return unless rules_value

            last_rule = rules_value.last

            if last_rule&.keys == [:when] && last_rule[:when] != 'never'
              docs_url = 'read more: https://docs.gitlab.com/ee/ci/troubleshooting.html#pipeline-warnings'
              add_warning("may allow multiple pipelines to run for a single action due to `rules:when` clause with no `workflow:rules` - #{docs_url}")
            end
          end

          def has_workflow_rules?
            strong_memoize(:has_workflow_rules) do
              !!ancestors.first&.try(:workflow_entry)&.has_rules?
            end
          end

          def name
            metadata[:name]
          end

          def overwrite_entry(deps, key, current_entry)
            return unless inherit_entry&.default_entry&.inherit?(key)
            return unless deps.default_entry

            deps.default_entry[key] unless current_entry.specified?
          end

          def value
            { name: name,
              stage: stage_value,
              extends: extends,
              rules: rules_value,
              job_variables: variables_value,
              root_variables_inheritance: root_variables_inheritance,
              only: only_value,
              except: except_value,
              resource_group: resource_group }.compact
          end

          def root_variables_inheritance
            inherit_entry&.variables_entry&.value
          end

          def manual_action?
            self.when == 'manual'
          end
        end
      end
    end
  end
end
