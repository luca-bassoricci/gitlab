# frozen_string_literal: true

module Ci
  class SecureFile < Ci::ApplicationRecord
    include FileStoreMounter
    include Limitable

    FILE_SIZE_LIMIT = 5.megabytes.freeze
    CHECKSUM_ALGORITHM = 'sha256'
    PARSABLE_EXTENSIONS = ['.cer', '.mobileprovision', '.p12'].freeze

    self.limit_scope = :project
    self.limit_name = 'project_ci_secure_files'

    belongs_to :project, optional: false

    validates :file, presence: true, file_size: { maximum: FILE_SIZE_LIMIT }
    validates :checksum, :file_store, :name, :project_id, presence: true
    validates :name, uniqueness: { scope: :project }

    serialize :metadata, Serializers::Json # rubocop:disable Cop/ActiveRecordSerialize
    validates :metadata, json_schema: { filename: 'ci_secure_file_metadata', hash_conversion: true }, allow_blank: true

    after_initialize :generate_key_data
    before_validation :assign_checksum

    scope :order_by_created_at, -> { order(created_at: :desc) }
    scope :project_id_in, ->(ids) { where(project_id: ids) }

    default_value_for(:file_store) { Ci::SecureFileUploader.default_store }

    mount_file_store_uploader Ci::SecureFileUploader

    def checksum_algorithm
      CHECKSUM_ALGORITHM
    end

    def metadata_parsable?
      PARSABLE_EXTENSIONS.include?(File.extname(name))
    end

    def metadata_parser_name
      File.extname(name).gsub(/^\./, '')
    end

    def metadata_parser
      return unless metadata_parsable?

      @metadata_parser ||= begin
        klass = metadata_parser_name.capitalize
        "Gitlab::Ci::SecureFiles::#{klass}".constantize
      end
    end

    def update_metadata
      return unless metadata_parser

      parser = metadata_parser.new(file.read)

      self.metadata = parser.metadata
      self.expires_at = parser.expires_at if parser.respond_to?(:expires_at)

      save!
    end

    private

    def assign_checksum
      self.checksum = file.checksum if file.present? && file_changed?
    end

    def generate_key_data
      return if key_data.present?

      self.key_data = SecureRandom.hex(64)
    end
  end
end

Ci::SecureFile.prepend_mod
