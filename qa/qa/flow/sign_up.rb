# frozen_string_literal: true

module QA
  module Flow
    module SignUp
      module_function

      def page
        Capybara.current_session
      end

      def sign_up!(user)
        Page::Main::Menu.perform(&:sign_out_if_signed_in)
        Page::Main::Login.perform(&:switch_to_register_page)
        Page::Registration::SignUp.perform do |sign_up|
          sign_up.fill_new_user_first_name_field(user.first_name)
          sign_up.fill_new_user_last_name_field(user.last_name)
          sign_up.fill_new_user_username_field(user.username)
          sign_up.fill_new_user_email_field(user.email)
          sign_up.fill_new_user_password_field(user.password)

          Support::Waiter.wait_until(sleep_interval: 0.5) do
            page.has_content?("Username is available.")
          end

          sign_up.click_new_user_register_button
        end

        Page::Registration::Welcome.perform do |welcome_page|
          if welcome_page.has_get_started_button?
            welcome_page.select_role('Other')
            welcome_page.choose_setup_for_company
            welcome_page.click_get_started_button
          end
        end

        Page::Registration::Groups.perform do |welcome_page|
          if welcome_page.has_create_group_button?
            welcome_page.set_group_name("group-at-registration_#{SecureRandom.hex(8)}")
            welcome_page.click_create_group_button
          end
        end

        Page::Registration::Projects.perform do |welcome_page|
          if welcome_page.has_create_project_button?
            welcome_page.set_project_name("project-at-registration_#{SecureRandom.hex(8)}")
            welcome_page.click_create_project_button
          end
        end

        Page::Registration::Welcome.perform(&:click_ok_lets_go_link)

        success = if user.expect_fabrication_success
                    Page::Main::Menu.perform(&:has_personal_area?)
                  else
                    Page::Main::Menu.perform(&:not_signed_in?)
                  end

        raise "Failed user registration attempt. Registration was expected to #{user.expect_fabrication_success ? 'succeed' : 'fail'} but #{success ? 'succeeded' : 'failed'}." unless success
      end

      def disable_sign_ups
        Flow::Login.sign_in_as_admin
        Page::Main::Menu.perform(&:go_to_admin_area)
        Page::Admin::Menu.perform(&:go_to_general_settings)

        Page::Admin::Settings::General.perform do |general_settings|
          general_settings.expand_sign_up_restrictions do |signup_settings|
            signup_settings.disable_signups
            signup_settings.save_changes
          end
        end
      end
    end
  end
end
