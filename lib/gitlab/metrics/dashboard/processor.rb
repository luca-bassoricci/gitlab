# frozen_string_literal: true

module Gitlab
  module Metrics
    module Dashboard
      # Responsible for processesing a dashboard hash, inserting
      # relevant DB records & sorting for proper rendering in
      # the UI. These includes shared metric info, custom metrics
      # info, and alerts (only in EE).
      class Processor
        SEQUENCE = [
          Stages::CommonMetricsInserter,
          Stages::ProjectMetricsInserter,
          Stages::Sorter
        ].freeze

        def initialize(project, environment)
          @project = project
          @environment = environment
        end

        # Returns a new dashboard hash with the results of
        # running transforms on the dashboard.
        def process(dashboard)
          dashboard = dashboard.deep_transform_keys(&:to_sym)

          stage_params = [@project, @environment]
          sequence.each { |stage| stage.new(*stage_params).transform!(dashboard) }

          dashboard
        end

        private

        def sequence
          SEQUENCE
        end
      end
    end
  end
end

Gitlab::Metrics::Dashboard::Processor.prepend EE::Gitlab::Metrics::Dashboard::Processor
