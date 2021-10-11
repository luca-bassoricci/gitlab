# frozen_string_literal: true

require 'spec_helper'

require_migration!

RSpec.describe CleanUpOrphanedDastSiteTokens do
  let_it_be(:namespaces) { table(:namespaces) }
  let_it_be(:projects) { table(:projects) }
  let_it_be(:dast_sites) { table(:dast_sites) }
  let_it_be(:dast_site_tokens) { table(:dast_site_tokens) }

  let!(:namespace) { namespaces.create!(id: 1, name: 'group', path: 'group') }
  let!(:project) { projects.create!(id: 1, namespace_id: namespace.id, path: 'project') }

  context 'when there are no dast_sites or dast_site_tokens' do
    describe 'migration up' do
      it 'does remove duplicated dast site tokens' do
        expect { migrate! }.not_to change(dast_site_tokens, :count)
      end
    end
  end

  context 'when there are some dast_sites and dast_site_tokens' do
    let!(:dast_site1) { dast_sites.create!(project_id: project.id, url: generate(:url)) }
    let!(:dast_site2) { dast_sites.create!(project_id: project.id, url: generate(:url)) }
    let!(:dast_site3) { dast_sites.create!(project_id: project.id, url: generate(:url)) }

    let!(:dast_site_token1) { dast_site_tokens.create!(project_id: project.id, token: SecureRandom.uuid, url: dast_site1.url) }
    let!(:dast_site_token2) { dast_site_tokens.create!(project_id: project.id, token: SecureRandom.uuid, url: dast_site2.url) }
    let!(:dast_site_token3) { dast_site_tokens.create!(project_id: project.id, token: SecureRandom.uuid, url: dast_site3.url) }
    let!(:dast_site_token4) { dast_site_tokens.create!(project_id: project.id, token: SecureRandom.uuid, url: generate(:url)) }
    let!(:dast_site_token5) { dast_site_tokens.create!(project_id: project.id, token: SecureRandom.uuid, url: generate(:url)) }

    it 'associates dast_sites and cleans up orphaned records', :aggregate_failures do
      expect { migrate! }.to change { dast_site_tokens.count }.from(5).to(3)

      expect(dast_site_token1.reload.dast_site_id).to eq(dast_site1.id)
      expect(dast_site_token2.reload.dast_site_id).to eq(dast_site2.id)
      expect(dast_site_token3.reload.dast_site_id).to eq(dast_site3.id)
    end
  end
end
