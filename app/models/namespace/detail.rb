# frozen_string_literal: true

# rubocop: disable  Gitlab/NamespacedClass
class Namespace
  class Detail < ApplicationRecord
    belongs_to :namespace, inverse_of: :namespace_details
    validates :namespace, presence: true
    validates :description, length: { maximum: 255 }

    self.primary_key = :namespace_id
  end
end
# rubocop: enable  Gitlab/NamespacedClass
