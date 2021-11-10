# frozen_string_literal: true

class Admin::IntegrationsController < Admin::ApplicationController
  include ActionView::Helpers::NumberHelper
  include ::Integrations::Actions

  OVERRIDES_COUNTER_LIMIT = 1000

  before_action :not_found, unless: -> { instance_level_integrations? }
  before_action :overrides_counter, only: [:edit, :overrides]

  feature_category :integrations

  def overrides
    respond_to do |format|
      format.json do
        serializer = ::Integrations::ProjectSerializer.new.with_pagination(request, response)

        render json: serializer.represent(projects)
      end
      format.html { render 'shared/integrations/overrides' }
    end
  end

  private

  def projects
    @projects ||= Project.with_active_integration(integration.class).merge(::Integration.with_custom_settings)
  end

  def overrides_counter
    count = projects.size
    @overrides_counter ||= if count >= OVERRIDES_COUNTER_LIMIT
                             "#{number_with_delimiter(OVERRIDES_COUNTER_LIMIT)}+"
                           else
                             number_with_delimiter(count)
                           end
  end

  def find_or_initialize_non_project_specific_integration(name)
    Integration.find_or_initialize_non_project_specific_integration(name, instance: true)
  end
end
