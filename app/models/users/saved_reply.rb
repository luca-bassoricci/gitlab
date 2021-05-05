# frozen_string_literal: true

module Users
  class SavedReply < ApplicationRecord
    belongs_to :user
    validates :user, presence: true
    validates :title, presence: true, uniqueness: true
  end
end
