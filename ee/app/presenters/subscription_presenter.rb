# frozen_string_literal: true

class SubscriptionPresenter < Gitlab::View::Presenter::Delegated
  GRACE_PERIOD_EXTENSION_DAYS = 14.days

  presents :subscription, ::Subscription

  def block_changes?
    will_block_changes? && (block_changes_at < Date.today)
  end

  def plan
    hosted_plan.name
  end

  def notify_admins?
    remaining_days && remaining_days < 30
  end

  def notify_users?
    false
  end

  def expires_at
    end_date
  end

  def block_changes_at
    return unless end_date

    end_date + GRACE_PERIOD_EXTENSION_DAYS
  end

  def remaining_days
    return unless end_date

    return 0 if expired?

    (end_date - Date.today).to_i
  end

  def will_block_changes?
    end_date.present?
  end
end
