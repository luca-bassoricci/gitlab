# frozen_string_literal: true

module Ci
  class PipelineDetails < Ci::ApplicationRecord
    self.primary_key = :pipeline_id

    belongs_to :pipeline, class_name: "Ci::Pipeline", inverse_of: :pipeline_details
    belongs_to :project, class_name: "Project"

    validates :pipeline, presence: true
    validates :project, presence: true
    validates :title, presence: true
  end
end
