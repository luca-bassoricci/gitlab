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

  let_it_be(:project) { create(:project, :repository, :public) }
  let_it_be(:pipeline) { create(:ci_pipeline, project: project) }
  let_it_be(:build_job) { create(:ci_build, :trace_with_sections, name: 'build-a', pipeline: pipeline) }
  let_it_be(:current_user) { create(:user) }

  # Simple schema to test this, since Pipeline.job(id:) is implemented in !44703
  # TODO: replace with real query when !44703 is merged.
  let_it_be(:pipeline_job_query_type) do
    trace_type = described_class

    query_factory do |t|
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
  end

  shared_examples 'a build-trace field' do |field_name|
    let(:the_field) { field_name }

    it 'retrieves the last 10 lines by default' do
      text = resolve_field(field_name, build_job.trace, current_user: current_user)

      expect(text.lines.length).to be <= 10
    end

    def pipeline_jobs_query(*link, **args)
      field_args = graphql_args(**args)
      prefix = [[:pipelines, { first: 1 }], :nodes, :jobs]
      link = %i[nodes] if link.empty?
      path = prefix + link + [:trace]

      graphql_query_for(
        :project, { full_path: project.full_path },
        query_graphql_path(path, query_graphql_field(the_field, field_args, ''))
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

    context "Pipeline.jobs.nodes.trace.#{field_name}(full: true)" do
      let(:query) { pipeline_jobs_query(:nodes, full: true) }

      it_behaves_like 'forbidden to request full trace'
    end

    context "Pipeline.jobs.nodes.trace.#{field_name}(full: true)" do
      let(:query) { pipeline_jobs_query(:edges, :node, full: true) }

      it_behaves_like 'forbidden to request full trace'
    end

    context 'We ask for more than the jobs tail length limit' do
      let(:query) { pipeline_jobs_query(tail: 100) }

      before do
        create(:ci_build, :with_long_trace, pipeline: pipeline)
      end

      it 'truncates the trace at the maximum value' do
        limit = described_class::MAX_TAIL_LENGTH_FOR_JOBS
        result = GitlabSchema.execute(query, context: { current_user: current_user }).to_h
        traces = graphql_dig_at(result, :data, :project, :pipelines, :nodes, :jobs, :nodes, :trace, field_name)

        expect(traces).to all(have_attributes(lines: have_attributes(size: be <= limit)))
      end
    end

    context 'We request more than the per-query limit of traces' do
      before do
        create_list(:ci_build, PerQueryLimits::PER_QUERY_LIMIT, :trace_with_sections, pipeline: pipeline)
      end

      it 'prevents loading that many traces' do
        query = pipeline_jobs_query

        result = GitlabSchema.execute(query, context: { current_user: current_user }).to_h

        expect(graphql_dig_at(result, :errors, :message)).to contain_exactly(
          'Maximum of 10 instances of BuildTrace per query'
        )
      end
    end

    it 'allows the use of full: true in Pipeline.job.trace' do
      long_trace_build = create(:ci_build, :with_long_trace, pipeline: pipeline)

      query = graphql_query_for(
        :pipeline, { id: pipeline.id },
        query_graphql_path(
          [[:job, { id: long_trace_build.id }], :trace],
          "#{field_name}(full: true)"
        )
      )

      result = execute_query(pipeline_job_query_type, gql: query, current_user: current_user).to_h

      expect(graphql_dig_at(result, :data, :pipeline, :job, :trace, field_name))
        .to eq(long_trace_build.trace.send(field_name))
    end

    context 'We ask for more than the jobs tail length limit' do
      let(:long_trace_build) { create(:ci_build, :with_long_trace, pipeline: pipeline) }

      let(:query) do
        graphql_query_for(
          :pipeline, { id: pipeline.id },
          query_graphql_path(
            [[:job, { id: long_trace_build.id }], :trace],
            query_graphql_field(field_name, { tail: 50 }, '')
          )
        )
      end

      # Our line counting counts the separators, not the lines themselves.
      it 'gives us what we ask for' do
        result = execute_query(pipeline_job_query_type, gql: query, current_user: current_user).to_h
        traces = graphql_dig_at(result, :data, :pipeline, :job, :trace, field_name)

        expect(traces.scan(line_separator)).to have_attributes(count: 50)
      end
    end
  end

  it_behaves_like 'a build-trace field', :raw do
    let(:line_separator) { /\n/ }
  end

  it_behaves_like 'a build-trace field', :html do
    let(:line_separator) { /<br\/>/ }
  end
end
