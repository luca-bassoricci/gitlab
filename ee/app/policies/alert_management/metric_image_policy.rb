# frozen_string_literal: true

module AlertManagement
  class MetricImagePolicy < BasePolicy
    delegate { @subject.alert }
  end
end
