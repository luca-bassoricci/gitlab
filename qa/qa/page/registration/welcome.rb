# frozen_string_literal: true

module QA
  module Page
    module Registration
      class Welcome < Page::Base
        view 'app/views/registrations/welcome/show.html.haml' do
          element :get_started_button
          element :role_dropdown
        end

        view 'ee/app/views/registrations/welcome/_setup_for_company.html.haml' do
          element :setup_for_company_radio
        end

        view 'ee/app/views/registrations/welcome/continuous_onboarding_getting_started.html.haml' do
          element :ok_lets_go_link
        end

        def has_get_started_button?
          has_element?(:get_started_button)
        end

        def choose_setup_for_company
          choose_element(:setup_for_company_radio)
        end

        def select_role(role)
          select_element(:role_dropdown, role)
        end

        def click_ok_lets_go_link
          click_element :ok_lets_go_link
        end

        def click_get_started_button
          Support::Retrier.retry_until do
            click_element :get_started_button
            has_no_element?(:get_started_button)
          end
        end
      end
    end
  end
end

QA::Page::Registration::Welcome.prepend_mod_with('Page::Registration::Welcome', namespace: QA)
