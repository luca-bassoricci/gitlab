# frozen_string_literal: true

module QA
  module Page
    module Registration
      class Groups < Page::Base
        view 'ee/app/views/registrations/groups/new.html.haml' do
          element :create_group_button
          element :group_name_text_field
        end

        def has_create_group_button?
          has_element? :create_group_button
        end

        def set_group_name(group_name)
          fill_element(:group_name_text_field, group_name)
        end

        def click_create_group_button
          click_element :create_group_button
        end
      end
    end
  end
end

QA::Page::Registration::Groups.prepend_mod_with('Page::Registration::Groups', namespace: QA)
