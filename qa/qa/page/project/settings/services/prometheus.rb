# frozen_string_literal: true

module QA
  module Page
    module Project
      module Settings
        module Services
          class Prometheus < Page::Base
            include Page::Component::CustomMetric

            view 'app/views/shared/integrations/prometheus/_custom_metrics.html.haml' do
              element :custom_metrics_container
            end

            def click_on_custom_metric(custom_metric)
              within_element :custom_metrics_container do
                click_on custom_metric
              end
            end

            def has_custom_metric?(custom_metric)
              within_element :custom_metrics_container do
                has_text? custom_metric
              end
            end
          end
        end
      end
    end
  end
end
