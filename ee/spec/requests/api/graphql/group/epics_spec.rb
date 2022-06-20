# frozen_string_literal: true

require 'spec_helper'

# Based on ee/spec/requests/api/epics_spec.rb
# Should follow closely in order to ensure all situations are covered
RSpec.describe 'Epics through GroupQuery' do
  include GraphqlHelpers

  let(:epics_data) { graphql_data['group']['epics']['edges'] }
  let(:epic_data) { graphql_data['group']['epic'] }

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:label) { create(:label) }
  let_it_be_with_reload(:epic) do
    create(:labeled_epic, group: group,
      state: :closed, created_at: 3.days.ago,
      updated_at: 2.days.ago, start_date: 2.days.ago,
      end_date: 4.days.ago, labels: [label]
    )
  end

  # similar to GET /groups/:id/epics
  describe 'Get list of epics from a group' do
    let(:epic_node) do
      <<~NODE
        edges {
          node {
            id
            iid
            title
            upvotes
            downvotes
            userPermissions {
              adminEpic
            }
          }
        }
      NODE
    end

    def query(params = {})
      graphql_query_for("group", { "fullPath" => group.full_path },
                        ['epicsEnabled',
                         query_graphql_field("epics", params, epic_node)]
      )
    end

    context 'when the request is correct' do
      before do
        stub_licensed_features(epics: true)
        post_graphql(query, current_user: user)
      end

      it_behaves_like 'a working graphql query'

      it 'returns epics successfully' do
        expect(response).to have_gitlab_http_status(:ok)
        expect(graphql_errors).to be_nil
        expect(epic_node_array('id').first).to eq epic.to_global_id.to_s
        expect(graphql_data['group']['epicsEnabled']).to be_truthy
      end
    end

    context 'with multiple epics' do
      let_it_be(:user2) { create(:user) }
      let_it_be(:epic2) { create(:epic, author: user2, group: group, title: 'foo', description: 'bar', created_at: 5.days.ago, updated_at: 3.days.ago, start_date: 3.days.ago, end_date: 3.days.ago ) }

      before do
        stub_licensed_features(epics: true)
      end

      context 'with sort and pagination' do
        let_it_be(:epic3) { create(:epic, group: group, start_date: 4.days.ago, end_date: 7.days.ago, created_at: 4.days.ago, updated_at: 1.day.ago ) }
        let_it_be(:epic4) { create(:epic, group: group, start_date: 5.days.ago, end_date: 6.days.ago ) }

        let(:current_user) { user }
        let(:data_path) { [:group, :epics] }

        def pagination_query(params)
          query =
            <<~QUERY
            epics(#{params}) {
              #{page_info}
              nodes { id }
            }
            QUERY

          graphql_query_for('group', { 'fullPath' => group.full_path }, ['epicsEnabled', query])
        end

        def global_ids(*epics)
          epics.map { |epic| global_id_of(epic).to_s }
        end

        context 'with start_date_asc' do
          it_behaves_like 'sorted paginated query', is_reversible: true do
            let(:sort_param) { :start_date_asc }
            let(:first_param) { 2 }
            let(:all_records) { global_ids(epic4, epic3, epic2, epic) }
          end
        end

        context 'with start_date_desc' do
          it_behaves_like 'sorted paginated query', is_reversible: true do
            let(:sort_param) { :start_date_desc }
            let(:first_param) { 2 }
            let(:all_records) { global_ids(epic, epic2, epic3, epic4) }
          end
        end

        context 'with end_date_asc' do
          it_behaves_like 'sorted paginated query', is_reversible: true do
            let(:sort_param) { :end_date_asc }
            let(:first_param) { 2 }
            let(:all_records) { global_ids(epic3, epic4, epic, epic2) }
          end
        end

        context 'with end_date_desc' do
          it_behaves_like 'sorted paginated query', is_reversible: true do
            let(:sort_param) { :end_date_desc }
            let(:first_param) { 2 }
            let(:all_records) { global_ids(epic2, epic, epic4, epic3) }
          end
        end

        context 'with created_at_asc' do
          it_behaves_like 'sorted paginated query', is_reversible: true do
            let(:sort_param) { :CREATED_AT_ASC }
            let(:first_param) { 2 }
            let(:all_records) { global_ids(epic2, epic3, epic, epic4) }
          end
        end

        context 'with created_at_desc' do
          it_behaves_like 'sorted paginated query', is_reversible: true do
            let(:sort_param) { :CREATED_AT_DESC }
            let(:first_param) { 2 }
            let(:all_records) { global_ids(epic4, epic, epic3, epic2) }
          end
        end

        context 'with updated_at_asc' do
          it_behaves_like 'sorted paginated query', is_reversible: true do
            let(:sort_param) { :UPDATED_AT_ASC }
            let(:first_param) { 2 }
            let(:all_records) { global_ids(epic2, epic, epic3, epic4) }
          end
        end

        context 'with updated_at_desc' do
          it_behaves_like 'sorted paginated query', is_reversible: true do
            let(:sort_param) { :UPDATED_AT_DESC }
            let(:first_param) { 2 }
            let(:all_records) { global_ids(epic4, epic3, epic, epic2) }
          end
        end
      end

      it 'sorts by created_at descending by default' do
        post_graphql(query, current_user: user)

        expect_array_response([epic2.to_global_id.to_s, epic.to_global_id.to_s])
      end

      it 'has upvote/downvote information' do
        create(:award_emoji, name: 'thumbsup', awardable: epic, user: user )
        create(:award_emoji, name: 'thumbsdown', awardable: epic2, user: user )

        post_graphql(query, current_user: user)

        expect(epic_node_array).to contain_exactly(
          a_hash_including('upvotes' => 1, 'downvotes' => 0),
          a_hash_including('upvotes' => 0, 'downvotes' => 1)
        )
      end

      describe 'can admin epics' do
        context 'when permission is absent' do
          it 'returns false for adminEpic' do
            post_graphql(query, current_user: user)

            expect(epic_node_array('userPermissions')).to all(include('adminEpic' => false))
          end
        end

        context 'when permission is present' do
          before do
            group.add_maintainer(user)
          end

          it 'returns true for adminEpic' do
            post_graphql(query, current_user: user)

            expect(epic_node_array('userPermissions')).to all(include('adminEpic' => true))
          end
        end
      end

      context 'query performance' do
        let_it_be(:child_epic) { create(:epic, group: group, parent: create(:epic, group: group)) }

        let(:epic_node) do
          <<~NODE
            edges {
              node {
                parent {
                  id
                }
              }
            }
          NODE
        end

        it 'avoids n+1 queries when loading parent field' do
          # warm up
          post_graphql(query({ iids: [child_epic.iid] }), current_user: user)

          control_count = ActiveRecord::QueryRecorder.new(skip_cached: false) do
            post_graphql(query({ iids: [child_epic.iid] }), current_user: user)
          end.count

          epics_with_parent = create_list(:epic, 3, group: group) do |epic|
            epic.update!(parent: create(:epic, group: group))
          end

          expect do
            post_graphql(query({ iids: epics_with_parent.pluck(:iid) }), current_user: user)
          end.not_to exceed_query_limit(control_count)
        end
      end

      context 'with negated filters' do
        it 'returns only matching epics' do
          filter_params = { not: { author_username: user2.username } }
          graphql_query = query(filter_params)

          post_graphql(graphql_query, current_user: user)

          expect_array_response([epic.to_global_id.to_s])
        end
      end

      context 'with top_level_hierarchy_only argument' do
        let_it_be(:child_epic) { create(:epic, group: group, parent: epic2) }

        it 'returns only top level matching epics when set as `true`' do
          graphql_query = query({ top_level_hierarchy_only: true })

          post_graphql(graphql_query, current_user: user)

          expect_array_response([epic2.to_global_id.to_s, epic.to_global_id.to_s])
        end

        it 'returns all matching epics when set as `false' do
          graphql_query = query({ top_level_hierarchy_only: false })

          post_graphql(graphql_query, current_user: user)

          expect_array_response([child_epic.to_global_id.to_s, epic2.to_global_id.to_s, epic.to_global_id.to_s])
        end
      end

      context 'filter' do
        context 'with search params' do
          it 'returns only matching epics' do
            filter_params = { search: 'bar', in: [:DESCRIPTION] }
            graphql_query = query(filter_params)

            post_graphql(graphql_query, current_user: user)

            expect_array_response([epic2.to_global_id.to_s])
          end
        end
      end
    end

    context 'when error requests' do
      context 'when epics feature is disabled' do
        it 'returns empty' do
          group.add_developer(user)

          post_graphql(query, current_user: user)

          expect(response).to have_gitlab_http_status(:success)
          expect(graphql_errors).to be_nil
          expect(epics_data).to be_empty
          expect(graphql_data['group']['epicsEnabled']).to be_falsey
        end

        context 'when epics feature is enabled' do
          before do
            stub_licensed_features(epics: true)
          end

          it 'returns a nil group for a user without permissions to see the group' do
            project.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)
            group.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)

            post_graphql(query, current_user: user)

            expect(response).to have_gitlab_http_status(:success)
            expect(graphql_errors).to be_nil
            expect(graphql_data['group']).to be_nil
          end
        end
      end
    end
  end

  # similar to 'GET /groups/:id/epics/:epic_iid'
  describe 'Get epic from a group' do
    let(:query) do
      graphql_query_for('group', { 'fullPath' => group.full_path },
                        ['epicsEnabled',
                         query_graphql_field('epic', { iid: epic.iid })]
      )
    end

    context 'when the request is correct' do
      before do
        stub_licensed_features(epics: true)

        post_graphql(query, current_user: user)
      end

      it_behaves_like 'a working graphql query'

      it 'returns an epic successfully' do
        expect(response).to have_gitlab_http_status(:success)
        expect(graphql_errors).to be_nil
        expect(epic_data['id']).to eq epic.to_global_id.to_s
        expect(graphql_data['group']['epicsEnabled']).to be_truthy
        expect(epic_data['confidential']).to be_falsey
      end
    end
  end

  describe 'N+1 query checks' do
    let_it_be(:epic_a) { create(:epic, group: group) }
    let_it_be(:epic_b) { create(:epic, group: group) }

    let(:epics) { [epic_a, epic_b] }
    let(:extra_iid_for_second_query) { epic_b.iid.to_s }
    let(:search_params) { { iids: [epic_a.iid.to_s] } }

    before do
      stub_licensed_features(epics: true)
    end

    context 'when requesting `user_notes_count`' do
      let(:requested_fields) { [:user_notes_count] }

      before do
        create_list(:note_on_epic, 2, noteable: epic_a)
        create(:note_on_epic, noteable: epic_b)
      end

      include_examples 'N+1 query check'
    end

    context 'when requesting `user_discussions_count`' do
      let(:requested_fields) { [:user_discussions_count] }

      before do
        create_list(:note_on_epic, 2, noteable: epic_a)
        create(:note_on_epic, noteable: epic_b)
      end

      include_examples 'N+1 query check'
    end

    context 'when requesting related epics fields' do
      before_all do
        create(:related_epic_link, link_type: IssuableLink::TYPE_BLOCKS, source: create(:epic, group: group), target: epic_a)
        create(:related_epic_link, link_type: IssuableLink::TYPE_BLOCKS, source: create(:epic, group: group), target: epic_b)
        create(:related_epic_link, link_type: IssuableLink::TYPE_BLOCKS, source: epic_a, target: create(:epic, group: group))
        create(:related_epic_link, link_type: IssuableLink::TYPE_BLOCKS, source: epic_b, target: create(:epic, group: group))
      end

      context 'when requesting `blocked`' do
        let(:requested_fields) { [:blocked] }

        include_examples 'N+1 query check'
      end

      context 'when requesting blocked_by_count' do
        let(:requested_fields) { [:blocked_by_count] }

        include_examples 'N+1 query check'
      end

      context 'when requesting blocking_count' do
        let(:requested_fields) { [:blocking_count] }

        include_examples 'N+1 query check'
      end
    end
  end

  describe 'Get related epic links fields' do
    let_it_be(:epic_a) { create(:epic, group: group) }
    let_it_be(:epic_b) { create(:epic, group: group, created_at: 1.hour.ago) }

    let(:search_params) { { iids: [epic_a.iid.to_s, epic_b.iid.to_s], sort: :CREATED_AT_DESC } }
    let(:requested_fields) { [:id, :blocked, :blocking_count, :blocked_by_count, 'blockedByEpics { nodes { title } }'] }

    before_all do
      create(:related_epic_link, link_type: IssuableLink::TYPE_BLOCKS, source: create(:epic, title: 'block1', group: group), target: epic_a)
      create(:related_epic_link, link_type: IssuableLink::TYPE_BLOCKS, source: create(:epic, title: 'block2', group: group), target: epic_a)
      create(:related_epic_link, link_type: IssuableLink::TYPE_BLOCKS, source: epic_a, target: create(:epic, group: group))
      create(:related_epic_link, link_type: IssuableLink::TYPE_BLOCKS, source: epic_b, target: create(:epic, group: group))
      create(:related_epic_link, link_type: IssuableLink::TYPE_BLOCKS, source: epic_b, target: create(:epic, group: group))
    end

    before do
      stub_licensed_features(epics: true)
    end

    it 'returns correct field values', :aggregate_failures do
      execute_query

      epic_1 = graphql_data_at(:group, :epics, :nodes)[0]
      epic_2 = graphql_data_at(:group, :epics, :nodes)[1]
      expect(epic_1).to match(a_hash_including('id' => epic_a.to_global_id.to_s, 'blocked' => true, 'blockingCount' => 1, 'blockedByCount' => 2))
      expect(epic_1['blockedByEpics']['nodes']).to match_array([{ "title" => "block1" }, { "title" => "block2" }])
      expect(epic_2).to match(a_hash_including('id' => epic_b.to_global_id.to_s, 'blocked' => false, 'blockingCount' => 2, 'blockedByCount' => 0))
      expect(epic_2['blockedByEpics']['nodes']).to be_empty
    end
  end

  def execute_query
    query = graphql_query_for(
      :group,
      { full_path: group.full_path },
      query_graphql_field(:epics, search_params, [
        query_graphql_field(:nodes, nil, requested_fields)
      ])
    )
    post_graphql(query, current_user: user)
  end

  def expect_array_response(items)
    expect(response).to have_gitlab_http_status(:success)
    expect(epics_data).to be_an Array
    expect(epic_node_array('id')).to eq(Array(items))
  end

  def epic_node_array(extract_attribute = nil)
    node_array(epics_data, extract_attribute)
  end
end
