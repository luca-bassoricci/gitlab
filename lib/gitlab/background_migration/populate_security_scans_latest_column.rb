# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # rubocop:disable Style/Documentation
    class PopulateSecurityScansLatestColumn
      NOP_RELATION = Class.new { def each_batch(*); end }

      def self.builds
        NOP_RELATION.new
      end

      def perform(*_); end
    end
  end
end

Gitlab::BackgroundMigration::PopulateSecurityScansLatestColumn.prepend_mod_with('Gitlab::BackgroundMigration::PopulateSecurityScansLatestColumn')
