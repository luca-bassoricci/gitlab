# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::Factory, factory_default: :keep do
  let_it_be(:project) { create_default(:project, :repository).freeze }
  let_it_be(:pipeline) { create(:ci_pipeline, :success) }

  describe '.fabricate' do
    subject(:report) { described_class.fabricate(report_type: report_type, pipeline: pipeline) }

    shared_examples 'parsing a report job artifact into a report' do
      context 'when there is no matching report type' do
        it 'returns an empty report' do
          expect(report).to be_empty
        end
      end

      context 'when the pipeline is a child pipeline' do
        let!(:pipeline) { create(:ci_pipeline, :success, child_of: build(:ci_pipeline)) }

        it 'returns an empty report' do
          expect(report).to be_empty
        end
      end
    end

    describe 'coverage report' do
      let!(:report_type) { :coverage }

      it_behaves_like 'parsing a report job artifact into a report'

      shared_examples 'having a coverage report' do
        it 'returns coverage reports with collected data' do
          expected_files = [
            "auth/token.go",
            "auth/rpccredentials.go",
            "app/controllers/abuse_reports_controller.rb"
          ]

          expect(report.files.keys).to match_array(expected_files)
        end
      end

      context 'when pipeline has multiple builds with coverage reports' do
        let!(:build_rspec) { create(:ci_build, :success, name: 'rspec', pipeline: pipeline) }
        let!(:build_golang) { create(:ci_build, :success, name: 'golang', pipeline: pipeline) }

        before do
          create(:ci_job_artifact, :cobertura, job: build_rspec)
          create(:ci_job_artifact, :coverage_gocov_xml, job: build_golang)
        end

        it_behaves_like 'having a coverage report'

        context 'and it is a child pipeline' do
          let!(:pipeline) { create(:ci_pipeline, :success, child_of: build(:ci_pipeline)) }

          it 'returns empty coverage report' do
            expect(report).to be_empty
          end
        end
      end

      context 'when builds are retried' do
        let!(:build_rspec) { create(:ci_build, :success, name: 'rspec', retried: true, pipeline: pipeline) }
        let!(:build_golang) { create(:ci_build, :success, name: 'golang', retried: true, pipeline: pipeline) }

        before do
          create(:ci_job_artifact, :cobertura, job: build_rspec)
          create(:ci_job_artifact, :coverage_gocov_xml, job: build_golang)
        end

        it 'does not take retried builds into account' do
          expect(report).to be_empty
        end
      end

      context 'when pipeline does not have any builds with coverage reports' do
        it 'returns empty coverage reports' do
          expect(report).to be_empty
        end
      end

      context 'when pipeline has child pipeline with builds that have coverage reports' do
        let!(:child_pipeline) { create(:ci_pipeline, :success, child_of: pipeline) }

        let!(:build_rspec) { create(:ci_build, :success, name: 'rspec', pipeline: child_pipeline) }
        let!(:build_golang) { create(:ci_build, :success, name: 'golang', pipeline: child_pipeline) }

        before do
          create(:ci_job_artifact, :cobertura, job: build_rspec)
          create(:ci_job_artifact, :coverage_gocov_xml, job: build_golang)
        end

        it_behaves_like 'having a coverage report'
      end

      context 'when both parent and child pipeline have builds with coverage reports' do
        let!(:child_pipeline) { create(:ci_pipeline, :success, child_of: pipeline) }

        let!(:build_rspec) { create(:ci_build, :success, name: 'rspec', pipeline: pipeline) }
        let!(:build_golang) { create(:ci_build, :success, name: 'golang', pipeline: child_pipeline) }

        before do
          create(:ci_job_artifact, :cobertura, job: build_rspec)
          create(:ci_job_artifact, :coverage_gocov_xml, job: build_golang)
        end

        it_behaves_like 'having a coverage report'
      end
    end
  end
end
