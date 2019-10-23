# frozen_string_literal: true

class PagesDomainRemovalCronWorker
  include ApplicationWorker
  include CronjobQueue

  feature_category :pages

  def perform
    PagesDomain.for_removal.find_each do |domain|
      domain.destroy!
    rescue => e
      Raven.capture_exception(e)
    end
  end
end
