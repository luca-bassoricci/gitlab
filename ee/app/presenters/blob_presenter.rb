# frozen_string_literal: true
require 'ipynbdiff'

module EE
  module BlobPresenter
    extend ::Gitlab::Utils::Override
    extend ::Gitlab::Utils::DelegatorOverride

    override :code_owners
    def code_owners
      Gitlab::CodeOwners.for_blob(project, blob)
    end
  end
end