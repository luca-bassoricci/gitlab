# frozen_string_literal: true

module EE
  module Key
    extend ActiveSupport::Concern

    include Auditable
    include ProfilesHelper

    prepended do
      include UsageStatistics

      scope :ldap, -> { where(type: 'LDAPKey') }

      validate :expiration, if: -> { ::Key.expiration_enforced? }

      with_options if: :ssh_key_expiration_policy_enabled? do
        validate :validate_expires_at_before_max_expiry_date
      end

      def expiration
        errors.add(:key, :expired_and_enforced, message: 'has expired and the instance administrator has enforced expiration') if expired?
      end

      # Returns true if the key is:
      # - Expired
      # - Expiration is enforced
      # - Not invalid for any other reason
      def only_expired_and_enforced?
        return false unless ::Key.expiration_enforced? && expired?

        errors.map(&:type).reject { |t| t.eql?(:expired_and_enforced) }.empty?
      end

      def validate_expires_at_before_max_expiry_date
        return errors.add(:key, message: 'has no expiration date but an expiration date is required for SSH keys on this instance. Contact the instance administrator.') if expires_at.blank?

        # when the key is not yet persisted the `created_at` field is nil
        max_expiry_date = (created_at.presence || Time.current) + ::Gitlab::CurrentSettings.max_ssh_key_lifetime.days
        errors.add(:key, message: 'has an invalid expiration date. Set a shorter lifetime for the key or contact the instance administrator.') if expires_at > max_expiry_date
      end
    end

    class_methods do
      def regular_keys
        where(type: ['LDAPKey', 'Key', nil])
      end

      def expiration_enforced?
        return false unless enforce_ssh_key_expiration_feature_available?

        ::Gitlab::CurrentSettings.enforce_ssh_key_expiration?
      end

      def enforce_ssh_key_expiration_feature_available?
        License.feature_available?(:enforce_ssh_key_expiration)
      end
    end

    def audit_details
      title
    end
  end
end
