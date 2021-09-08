# frozen_string_literal: true

module Ci
  class ProcessablePresenter < CommitStatusPresenter
    delegator_target ::Ci::Processable
  end
end
