# frozen_string_literal: true

# NOTE: The patterns first introduced in this helper for doing trial-related
# callouts are mimicked by the PaidFeatureCalloutHelper. A third reuse of these
# patterns (especially as these experiments finish & become permanent parts of
# the codebase) could trigger the need to extract these patterns into a single,
# reusable, sharable helper.
module TrialStatusWidgetHelper
  def trial_status_popover_data_attrs(group)
    base_attrs = trial_status_common_data_attrs(group)
    base_attrs.merge(
      group_name: group.name,
      purchase_href: ultimate_subscription_path_for_group(group),
      target_id: base_attrs[:container_id],
      trial_end_date: group.trial_ends_on
    )
  end

  def trial_status_widget_data_attrs(group)
    trial_status_common_data_attrs(group).merge(
      days_remaining: group.trial_days_remaining,
      nav_icon_image_path: image_path('illustrations/golden_tanuki.svg'),
      percentage_complete: group.trial_percentage_complete
    )
  end

  def show_trial_status_widget?(group)
    billing_plans_and_trials_available? && eligible_for_trial_upgrade_callout?(group)
  end

  private

  def billing_plans_and_trials_available?
    ::Gitlab::CurrentSettings.should_check_namespace_plan?
  end

  def eligible_for_trial_upgrade_callout?(group)
    group.trial_active? && can?(current_user, :admin_namespace, group)
  end

  def trial_status_common_data_attrs(group)
    {
      container_id: 'trial-status-sidebar-widget',
      plan_name: group.gitlab_subscription&.plan_title,
      plans_href: group_billings_path(group)
    }
  end

  def ultimate_subscription_path_for_group(group)
    # NOTE: We are okay hard-coding the production value for the Ulitmate 1-year
    # SaaS plan ID while this is all part of an active experiment. If & when the
    # experiment is deemed a success, part of the clean-up effort will be to
    # pull the value directly from the CustomersDot API. Value taken from
    # https://gitlab.com/gitlab-org/customers-gitlab-com/blob/7177f13c478ef623b779d6635c4a58ee650b7884/config/application.yml#L207
    zuora_ultimate_plan_id = '2c92a0ff76f0d5250176f2f8c86f305a'

    new_subscriptions_path(namespace_id: group.id, plan_id: zuora_ultimate_plan_id)
  end
end
