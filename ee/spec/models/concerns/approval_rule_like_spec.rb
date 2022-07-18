# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApprovalRuleLike do
  let_it_be(:user1) { create(:user) }
  let_it_be(:user2) { create(:user) }
  let_it_be(:guest) { create(:user) }
  let_it_be(:group1) { create(:group) }
  let_it_be(:group2) { create(:group) }
  let_it_be(:group2_1) { create(:group, parent: group2) }

  shared_examples 'approval rule like' do
    describe '#approvers' do
      let_it_be(:group1_user) { create(:user) }
      let_it_be(:group2_user) { create(:user) }
      let_it_be(:group2_1_user) { create(:user) }

      before do
        subject.users << user1
        subject.users << user2
        subject.groups << group1
        subject.groups << group2_1

        group1.add_developer(group1_user)
        group1.add_guest(guest)
        group2.add_maintainer(group2_user)
        group2_1.add_owner(group2_1_user)
      end

      shared_examples 'approvers contains the right users' do
        it 'contains users as direct members, group members and inherited group members' do
          expect(subject.approvers).to contain_exactly(user1, user2, group1_user, group2_user, group2_1_user)
        end
      end

      it_behaves_like 'approvers contains the right users'

      context 'when the user relations are already loaded' do
        before do
          subject.users
          subject.group_users
        end

        it 'does not perform any new queries when all users are loaded already' do
          # single query is triggered for license check
          expect { subject.approvers }.not_to exceed_query_limit(1)
        end

        it_behaves_like 'approvers contains the right users'
      end

      context 'when user is both a direct member, a group member and a inherited group member' do
        before do
          group1.add_developer(user1)
          group2.add_developer(user2)
          group2.add_developer(group2_1_user)
        end

        it 'contains only unique users' do
          expect(subject.approvers).to contain_exactly(user1, user2, group1_user, group2_user, group2_1_user)
        end
      end
    end

    describe 'validation' do
      context 'when value is too big' do
        it 'is invalid' do
          subject.approvals_required = described_class::APPROVALS_REQUIRED_MAX + 1

          expect(subject).to be_invalid
          expect(subject.errors.key?(:approvals_required)).to eq(true)
        end
      end

      context 'when value is within limit' do
        it 'is valid' do
          subject.approvals_required = described_class::APPROVALS_REQUIRED_MAX

          expect(subject).to be_valid
        end
      end

      context 'with report_type set to report_approver' do
        before do
          subject.rule_type = :report_approver
        end

        it 'is invalid' do
          subject.report_type = nil
          expect(subject).not_to be_valid
        end
      end
    end
  end

  context 'MergeRequest' do
    subject { create(:approval_merge_request_rule, merge_request: merge_request) }

    let_it_be(:merge_request) { create(:merge_request) }

    it_behaves_like 'approval rule like'

    describe '#overridden?' do
      it 'returns false' do
        expect(subject.overridden?).to be_falsy
      end

      context 'when rule has source rule' do
        let(:source_rule) do
          create(
            :approval_project_rule,
            project: merge_request.target_project,
            name: 'Source Rule',
            approvals_required: 2,
            users: [user1, user2],
            groups: [group1, group2]
          )
        end

        before do
          subject.update!(approval_project_rule: source_rule)
        end

        context 'and any attributes differ from source rule' do
          shared_examples_for 'overridden rule' do
            it 'returns true' do
              expect(subject.overridden?).to be_truthy
            end
          end

          context 'name' do
            before do
              subject.update!(name: 'Overridden Rule')
            end

            it_behaves_like 'overridden rule'
          end

          context 'approvals_required' do
            before do
              subject.update!(approvals_required: 1)
            end

            it_behaves_like 'overridden rule'
          end

          context 'users' do
            before do
              subject.update!(users: [user1])
            end

            it_behaves_like 'overridden rule'
          end

          context 'groups' do
            before do
              subject.update!(groups: [group1])
            end

            it_behaves_like 'overridden rule'
          end
        end

        context 'and no changes made to attributes' do
          before do
            subject.update!(
              name: source_rule.name,
              approvals_required: source_rule.approvals_required,
              users: source_rule.users,
              groups: source_rule.groups
            )
          end

          it 'returns false' do
            expect(subject.overridden?).to be_falsy
          end
        end
      end
    end
  end

  context 'Project' do
    subject { create(:approval_project_rule) }

    it_behaves_like 'approval rule like'

    describe '#overridden?' do
      it 'returns false' do
        expect(subject.overridden?).to be_falsy
      end
    end
  end

  describe '.group_users' do
    subject { create(:approval_project_rule) }

    it 'returns distinct users' do
      group1.add_developer(user1)
      group2.add_developer(user1)
      subject.groups = [group1, group2]

      expect(subject.group_users).to eq([user1])
    end
  end

  describe '.group_users_with_inheritance' do
    subject { create(:approval_project_rule) }

    it 'returns indirect members of the group' do
      subject.groups = [group2_1]

      group2.add_developer(user1)
      group2_1.add_developer(user2)

      expect(subject.group_users_with_inheritance).to match_array([user1, user2])
    end

    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(use_inherited_permissions_for_approval_rules: false)
      end

      it 'returns only direct members of the group' do
        subject.groups = [group2_1]

        group2.add_developer(user1)
        group2_1.add_developer(user2)

        expect(subject.group_users_with_inheritance).to match_array([user2])
      end
    end
  end
end
