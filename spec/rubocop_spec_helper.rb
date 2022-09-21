# frozen_string_literal: true

# All RuboCop specs may use fast_spec_helper.
require 'fast_spec_helper'

# To prevent load order issues we need to require `rubocop` first.
# See https://gitlab.com/gitlab-org/gitlab/-/merge_requests/47008
require 'rubocop'
require 'rubocop/rspec/support'

require_relative './support/shared_contexts/rubocop_default_rspec_language_config_context'

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{spec/rubocop}) do |metadata|
    # TODO: move DuplicateSpecLocation cop to RSpec::DuplicateSpecLocation
    unless metadata[:type] == :rubocop_rspec
      metadata[:type] = :rubocop
    end
  end

  config.define_derived_metadata(file_path: %r{spec/rubocop/cop/rspec}) do |metadata|
    metadata[:type] = :rubocop_rspec
  end

  config.include RuboCop::RSpec::ExpectOffense, type: :rubocop
  config.include RuboCop::RSpec::ExpectOffense, type: :rubocop_rspec

  config.include_context 'config', type: :rubocop
  config.include_context 'with default RSpec/Language config', type: :rubocop_rspec
end
