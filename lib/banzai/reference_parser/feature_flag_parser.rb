# frozen_string_literal: true

module Banzai
  module ReferenceParser
    class FeatureFlagParser < BaseParser
      extend ::Gitlab::Utils::Override

      self.reference_type = :feature_flag

      def self.reference_model
        Operations::FeatureFlag
      end

      def references_relation
        self.class.reference_model
      end

      private

      def can_read_reference?(user, feature_flag, node)
        can?(user, :read_feature_flag, feature_flag)
      end
    end
  end
end
