# frozen_string_literal: true

module Gitlab
  module Ci
    module Status
      module Bridge
        class Retried < Status::Extended
          def status_tooltip
            @status.status_tooltip + " (retried)"
          end

          def self.matches?(bridge, user)
            bridge.retried?
          end
        end
      end
    end
  end
end
