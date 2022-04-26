# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Audit::ProjectSettingChangesAuditor do
  using RSpec::Parameterized::TableSyntax
  describe '#execute' do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project) }
    let_it_be(:project_setting_changes_auditor) { described_class.new(user, project.project_setting, project) }

    before do
      stub_licensed_features(extended_audit_events: true)
    end

    context 'when project setting is updated' do
      options = ProjectSetting.squash_options.keys
      options.each do |prev_value|
        options.each do |new_value|
          context 'when squash option is changed' do
            before do
              project.project_setting.update!(squash_option: prev_value)
            end

            if new_value != prev_value
              it 'creates an audit event' do
                project.project_setting.update!(squash_option: new_value)

                expect { project_setting_changes_auditor.execute }.to change { AuditEvent.count }.by(1)
                expect(AuditEvent.last.details).to include(
                  {
                    custom_message: "Changed squash option to #{project.project_setting.human_squash_option}"
                  })
              end
            else
              it 'does not create audit event' do
                project.project_setting.update!(squash_option: new_value)
                expect { project_setting_changes_auditor.execute }.to not_change { AuditEvent.count }
              end
            end
          end
        end
      end

      context 'when allow_merge_on_skipped_pipeline is changed' do
        where(:prev_value, :new_value) do
          true  | false
          false | true
        end

        before do
          project.project_setting.update!(allow_merge_on_skipped_pipeline: prev_value)
        end

        with_them do
          it 'creates an audit event' do
            project.project_setting.update!(allow_merge_on_skipped_pipeline: new_value)

            expect { project_setting_changes_auditor.execute }.to change { AuditEvent.count }.by(1)
            expect(AuditEvent.last.details).to include({
                                                         change: 'allow_merge_on_skipped_pipeline',
                                                         from: prev_value,
                                                         to: new_value
                                                       })
          end
        end
      end
    end
  end
end
