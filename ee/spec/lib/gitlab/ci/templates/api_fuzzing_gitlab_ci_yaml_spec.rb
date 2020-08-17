# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'API-Fuzzing.gitlab-ci.yml' do
  subject(:template) { Gitlab::Template::GitlabCiYmlTemplate.find('API-Fuzzing') }

  describe 'the created pipeline' do
    let(:user) { create(:admin) }
    let(:default_branch) { 'master' }
    let(:pipeline_branch) { default_branch }
    let(:project) { create(:project, :custom_repo, files: { 'README.txt' => '' }) }
    let(:service) { Ci::CreatePipelineService.new(project, user, ref: pipeline_branch ) }
    let(:pipeline) { service.execute!(:push) }
    let(:build_names) { pipeline.builds.pluck(:name) }

    before do
      stub_ci_pipeline_yaml_file(template.content)
      allow_any_instance_of(Ci::BuildScheduleWorker).to receive(:perform).and_return(true)
      allow(project).to receive(:default_branch).and_return(default_branch)
    end

    context 'when project has no license' do
      before do
        create(:ci_variable, project: project, key: 'FUZZAPI_HAR', value: 'testing.har')
        create(:ci_variable, project: project, key: 'FUZZAPI_TARGET_URL', value: 'http://example.com')
      end

      it 'includes no jobs' do
        expect { pipeline }.to raise_error(Ci::CreatePipelineService::CreateError)
      end
    end

    context 'when project has Ultimate license' do
      let(:license) { create(:license, plan: License::ULTIMATE_PLAN) }

      before do
        allow(License).to receive(:current).and_return(license)
      end

      context 'by default' do
        it 'includes no jobs' do
          expect { pipeline }.to raise_error(Ci::CreatePipelineService::CreateError)
        end
      end

      context 'when FUZZAPI_HAR is present' do
        before do
          create(:ci_variable, project: project, key: 'FUZZAPI_HAR', value: 'testing.har')
          create(:ci_variable, project: project, key: 'FUZZAPI_TARGET_URL', value: 'http://example.com')
        end

        it 'includes job' do
          expect(build_names).to match_array(%w[apifuzzer_fuzz])
        end
      end

      context 'when FUZZAPI_OPENAPI is present' do
        before do
          create(:ci_variable, project: project, key: 'FUZZAPI_OPENAPI', value: 'openapi.json')
          create(:ci_variable, project: project, key: 'FUZZAPI_TARGET_URL', value: 'http://example.com')
        end

        it 'includes job' do
          expect(build_names).to match_array(%w[apifuzzer_fuzz])
        end
      end
    end

    context 'when API_FUZZING_DISABLED=1' do
      before do
        create(:ci_variable, project: project, key: 'FUZZAPI_HAR', value: 'testing.har')
        create(:ci_variable, project: project, key: 'FUZZAPI_TARGET_URL', value: 'http://example.com')
        create(:ci_variable, project: project, key: 'API_FUZZING_DISABLED', value: '1')
      end

      it 'includes no jobs' do
        expect { pipeline }.to raise_error(Ci::CreatePipelineService::CreateError)
      end
    end
  end
end
