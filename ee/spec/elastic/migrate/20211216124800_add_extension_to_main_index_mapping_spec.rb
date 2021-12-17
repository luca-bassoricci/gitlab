# frozen_string_literal: true

require 'spec_helper'
require_relative 'migration_shared_examples'
require File.expand_path('ee/elastic/migrate/20211216124800_add_extension_to_main_index_mapping.rb')

RSpec.describe AddExtensionToMainIndexMapping, :elastic, :sidekiq_inline do
  let(:version) { 20211216124800 }

  include_examples 'migration adds mapping'
end
