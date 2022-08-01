# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class Factory
        include Gitlab::Utils::StrongMemoize

        REPORTS = {
          coverage: CoverageReport
        }.freeze

        JOB_ARTIFACT_SCOPE = {
          coverage: ::Ci::JobArtifact.coverage_reports
        }.freeze

        def self.fabricate(report_type:, pipeline:)
          new(report_type: report_type, pipeline: pipeline).report
        end

        def initialize(report_type:, pipeline:)
          @report_type = report_type
          @pipeline = pipeline
        end

        def report
          report = REPORTS.fetch(@report_type).new

          # Return an empty report if the pipeline is a child pipeline.
          # Since the report is used in a merge request report,
          # we are only interested in the report from the root pipeline.
          return report if @pipeline.child?

          report.tap do |report|
            report_builds.find_each do |build|
              build.each_report(report_file_types) do |file_type, blob|
                Gitlab::Ci::Parsers.fabricate!(file_type, blob, report, pipeline: @pipeline).parse!
              end
            end
          end
        end

        private

        def report_builds
          scope = JOB_ARTIFACT_SCOPE.fetch(@report_type)

          @pipeline.latest_report_builds_in_self_and_descendants(scope)
        end

        def report_file_types
          ::Ci::JobArtifact.file_types_for_report(@report_type)
        end
      end
    end
  end
end
