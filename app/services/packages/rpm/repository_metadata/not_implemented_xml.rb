# frozen_string_literal: true
module Packages
  module Rpm
    module RepositoryMetadata
      class NotImplementedXml
        ROOT_TAG = 'notimplemented'
        ROOT_ATTRIBUTES = {}.freeze

        def execute
          ''
        end
      end
    end
  end
end
