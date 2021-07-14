# frozen_string_literal: true

class ChangeDevopsAdoptionSecurityScanNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :analytics_devops_adoption_snapshots, :security_scan_succeeded, true
  end
end
