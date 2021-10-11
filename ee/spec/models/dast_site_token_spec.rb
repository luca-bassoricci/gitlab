# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteToken, type: :model do
  subject { create(:dast_site_token) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:dast_site) }
  end

  describe 'validations' do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:project_id) }
    it { is_expected.to validate_length_of(:token).is_at_most(255) }
    it { is_expected.to validate_presence_of(:token) }
    it { is_expected.to validate_uniqueness_of(:token) }
    it { is_expected.to validate_presence_of(:dast_site_id) }
  end
end
