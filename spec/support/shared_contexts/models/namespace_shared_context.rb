# frozen_string_literal: true

RSpec.shared_context 'project bot users' do
  let(:project_bot) { create(:user, :project_bot) }

  before do
    project.add_maintainer(project_bot)
  end
end
