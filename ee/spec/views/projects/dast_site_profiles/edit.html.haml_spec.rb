# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "projects/dast_site_profiles/edit", type: :view do
  before do
    @project = create(:project)
    @site_profile = create(:dast_site_profile)
    @site_profile_gid = ::URI::GID.parse("gid://gitlab/DastSiteProfile/#{@site_profile.id}")
    render
  end

  it 'renders Vue app root' do
    expect(rendered).to have_selector('.js-dast-site-profile-form')
  end

  it 'passes project\'s full path' do
    expect(rendered).to include @project.path_with_namespace
  end

  it 'passes DAST profiles library URL' do
    expect(rendered).to include '/on_demand_scans/profiles'
  end

  it 'passes DAST site profile\'s data' do
    expect(rendered).to include @site_profile_gid.to_s
    expect(rendered).to include @site_profile.name
    expect(rendered).to include @site_profile.dast_site.url
  end
end
