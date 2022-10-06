# frozen_string_literal: true

module AlertManagement
  class MetricImage < ApplicationRecord
    include MetricImageUploading
    include ::Geo::ReplicableModel
    include ::Geo::VerifiableModel

    self.table_name = 'alert_management_alert_metric_images'

    belongs_to :alert, class_name: 'AlertManagement::Alert', foreign_key: 'alert_id', inverse_of: :metric_images
    has_one :alert_metric_image_state,
            autosave: false,
            inverse_of: :alert_management_alert_metric_image,
            class_name: '::Geo::AlertMetricImageState'

    with_replicator Geo::AlertMetricImageReplicator

    delegate(*::Geo::VerificationState::VERIFICATION_METHODS, to: :alert_management_alert_metric_image_state)

    mount_uploader :file, AlertManagement::MetricImageUploader

    after_save :save_verification_details

    scope :with_verification_state, ->(state) {
      joins(:alert_metric_image_state).where(
        alert_metric_image_states: {
          verification_state: verification_state_value(state)
        }
      )
    }
    scope :checksummed, -> {
      joins(:alert_metric_image_state).where.not(alert_metric_image_states: { verification_checksum: nil } )
    }
    scope :not_checksummed, -> {
      joins(:alert_metric_image_state).where(
        alert_metric_image_states: { verification_checksum: nil }
      )
    }

    scope :available_verifiables, -> { joins(:alert_metric_image_state) }

    # Override the `all` default if not all records can be replicated. For an
    # example of an existing Model that needs to do this, see
    # `EE::MergeRequestDiff`.
    # scope :available_replicables, -> { all }

    def verification_state_object
      alert_metric_image_state
    end

    def alert_management_alert_metric_image_state
      super || build_alert_metric_image_state
    end

    private

    def local_path
      Gitlab::Routing.url_helpers.alert_metric_image_upload_path(
        filename: file.filename,
        id: file.upload.model_id,
        model: model_name.param_key,
        mounted_as: 'file'
      )
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      # @param primary_key_in [Range, AlertManagement::MetricImage] arg to pass to primary_key_in scope
      # @return [ActiveRecord::Relation] everything that should be synced to this node, restricted by primary key
      def self.replicables_for_current_secondary(primary_key_in)
        # This issue template does not help you write this method.
        #
        # This method is called only on Geo secondary sites. It is called when
        # we want to know which records to replicate. This is not easy to automate
        # because for example:
        #
        # * The "selective sync" feature allows admins to choose which namespaces
        #   to replicate, per secondary site. Most Models are scoped to a
        #   namespace, but the nature of the relationship to a namespace varies
        #   between Models.
        # * The "selective sync" feature allows admins to choose which shards to
        #   replicate, per secondary site. Repositories are associated with
        #   shards. Most blob types are not, but Project Uploads are.
        # * Remote stored replicables are not replicated, by default. But the
        #   setting `sync_object_storage` enables replication of remote stored
        #   replicables.
        #
        # Search the codebase for examples, and consult a Geo expert if needed.
      end

      override :verification_state_table_class
      def verification_state_table_class
        AlertManagement::MetricImageState
      end
    end
  end
end
