# frozen_string_literal: true
module BoardHelpers
  def load_epic_swimlanes
    page.within('.board-swimlanes-toggle-wrapper') do
      page.find('.dropdown-toggle').click
      page.find('.dropdown-item', text: 'Epic').click
    end

    wait_for_requests
  end
end
