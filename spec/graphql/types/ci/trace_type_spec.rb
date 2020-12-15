# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Ci::TraceType do
  include GraphqlHelpers

  specify { expect(described_class.graphql_name).to eq('BuildTrace') }

  it 'has specific fields' do
    fields = %i[
      raw html sections
    ]

    fields.each do |field_name|
      expect(described_class).to have_graphql_field(field_name)
    end
  end

  describe '.raw' do
    let_it_be(:project) { create(:project, :repository, :public) }
    let_it_be(:pipeline) { create(:ci_pipeline, project: project) }
    let_it_be(:build_job) { create(:ci_build, :trace_with_sections, name: 'build-a', pipeline: pipeline) }
    let_it_be(:current_user) { create(:user) }

    it 'retrieves the last 10 lines by default' do
      text = resolve_field(:raw, build_job.trace, current_user: current_user)

      expect(text.lines.length).to be <= 10
    end

    def pipeline_jobs_query(*path_to_trace)
      prefix = [[:pipelines, { first: 1 }], :nodes, :jobs]

      graphql_query_for(
        :project, { full_path: project.full_path },
        query_graphql_path(prefix + path_to_trace, 'raw(full: true)')
      )
    end

    shared_examples 'forbidden to request full trace' do
      it 'forbids the use of full' do
        result = GitlabSchema.execute(query, context: { current_user: current_user }).to_h

        expect(graphql_dig_at(result, :errors, :message)).to contain_exactly(
          'Cannot request full trace from Pipeline.jobs'
        )
      end
    end

    context 'Pipeline.jobs.nodes.trace.raw(full: true)' do
      let(:query) { pipeline_jobs_query(:nodes, :trace) }

      it_behaves_like 'forbidden to request full trace'
    end

    context 'Pipeline.jobs.nodes.trace.raw(full: true)' do
      let(:query) { pipeline_jobs_query(:edges, :node, :trace) }

      it_behaves_like 'forbidden to request full trace'
    end

    it 'allows the use of full: true in Pipeline.job.trace' do
      # Simple schema to test this, since Pipeline.job(id:) is implemented in !44703
      # TODO: replace with real query when !44703 is merged.
      query = graphql_query_for(
        :pipeline, { id: pipeline.id },
        query_graphql_path(
          [[:job, { id: build_job.id }], :trace],
          'raw(full: true)'
        )
      )

      trace_type = described_class

      query_type = query_factory do |t|
        job_type = t.type('Job') do
          field :trace, trace_type, null: true

          def trace
            object.trace
          end
        end

        pipeline_type = t.type('Pipeline') do
          field :job, job_type, null: true do
            argument :id, GraphQL::INT_TYPE, required: true
          end

          def job(id:)
            object.statuses.id_in(id).first
          end
        end

        t.field :pipeline, pipeline_type, null: true do
          argument :id, GraphQL::INT_TYPE, required: true
        end

        t.class_eval do
          def pipeline(id:)
            ::Ci::Pipeline.id_in(id).first
          end
        end
      end

      result = execute_query(query_type, gql: query, current_user: current_user).to_h

      expect(graphql_dig_at(result, :data, :pipeline, :job, :trace, :raw)).to eq(build_job.trace.raw)
    end
  end
end
