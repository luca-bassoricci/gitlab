# frozen_string_literal: true

module QA
  module Page
    module Registration
      class Projects < Page::Base
        view 'ee/app/views/registrations/projects/new.html.haml' do
          element :create_project_button
          element :project_name_text_field
        end

        def has_create_project_button?
          has_element? :create_project_button
        end

        def set_project_name(project_name)
          fill_element(:project_name_text_field, project_name)
        end

        def click_create_project_button
          click_element :create_project_button
        end
      end
    end
  end
end

QA::Page::Registration::Projects.prepend_mod_with('Page::Registration::Projects', namespace: QA)
