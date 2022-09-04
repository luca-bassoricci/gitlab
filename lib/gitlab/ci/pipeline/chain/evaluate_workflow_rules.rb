# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        class EvaluateWorkflowRules < Chain::Base
          include ::Gitlab::Utils::StrongMemoize
          include Chain::Helpers

          def perform!
            @command.workflow_rules_result = workflow_rules_result

            set_pipeline_title

            error('Pipeline filtered out by workflow rules.') unless workflow_passed?
          end

          def break?
            @pipeline.errors.any? || @pipeline.persisted?
          end

          private

          def set_pipeline_title
            return unless workflow_rules_result.title.present?

            title = ExpandVariables.expand(workflow_rules_result.title, global_context.variables_hash)

            if @pipeline.pipeline_details.present?
              @pipeline.pipeline_details.title = title
            else
              @pipeline.build_pipeline_details(title: title, project: @pipeline.project)
            end
          end

          def workflow_passed?
            workflow_rules_result.pass?
          end

          def workflow_rules_result
            strong_memoize(:workflow_rules_result) do
              workflow_rules.evaluate(@pipeline, global_context)
            end
          end

          def workflow_rules
            Gitlab::Ci::Build::Rules.new(
              workflow_rules_config, default_when: 'always')
          end

          def global_context
            strong_memoize(:global_context) do
              Gitlab::Ci::Build::Context::Global.new(
                @pipeline, yaml_variables: @command.yaml_processor_result.root_variables)
            end
          end

          def has_workflow_rules?
            workflow_rules_config.present?
          end

          def workflow_rules_config
            strong_memoize(:workflow_rules_config) do
              @command.yaml_processor_result.workflow_rules
            end
          end
        end
      end
    end
  end
end
