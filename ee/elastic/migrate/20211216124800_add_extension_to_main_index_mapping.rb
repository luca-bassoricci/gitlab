# frozen_string_literal: true

class AddExtensionToMainIndexMapping < Elastic::Migration
  include Elastic::MigrationUpdateMappingsHelper

  private

  def index_name
    helper.target_index_name
  end

  def new_mappings
    {
      blob: {
        properties: {
          extension: {
            type: 'keyword'
          }
        }
      }
    }
  end
end
