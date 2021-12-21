# frozen_string_literal: true

require 'spec_helper'
require File.expand_path('ee/elastic/migrate/20211221100400_populate_extension_in_main_index.rb')

RSpec.describe PopulateExtensionInMainIndex do
  let(:version) { 20211221100400 }
  let(:migration) { described_class.new(version) }
  let(:index_name) { es_helper.target_name }
  let(:helper) { Gitlab::Elastic::Helper.new }

  before do
    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
    allow(migration).to receive(:helper).and_return(helper)
  end

  describe 'migration_options' do
    it 'has migration options set', :aggregate_failures do
      expect(migration.batched?).to be_truthy
      expect(migration.throttle_delay).to eq(1.minute)
    end
  end

  describe 'UPDATE_SCRIPT' do
    using RSpec::Parameterized::TableSyntax

    where(:file_name, :result) do
      nil                      | ''
      '.gitignore'             | ''
      '.hidden_file.conf'      | 'conf'
      'index.md'               | 'md'
      'default.config.example' | 'example'
    end

    with_them do
      it 'returns correct result' do
        expect(execute_script_for(file_name)).to eq(result)
      end
    end
  end

  def execute_script_for(file_name)
    script = "def ctx = params.ctx; #{described_class::UPDATE_SCRIPT.tr("\n", " ")}"

    body = {
      script: {
        source: script,
        params: {
          ctx: {
            _source: {
              blob: {
                file_name: file_name
              }
            }
          }
        }
      }
    }

    helper.client.scripts_painless_execute(body: body)['result']
  end
end
