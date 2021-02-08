# frozen_string_literal: true

module EE
  module Notes
    module CreateService
      extend ::Gitlab::Utils::Override

      override :when_saved
      def when_saved(note)
        super

        ::FeatureFlagIssues::CreateService.create_link_from_note(note, current_user)
      end
    end
  end
end
