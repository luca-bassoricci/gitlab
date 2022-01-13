# frozen_string_literal: true

default_base_url = "https://about#{'.staging' if ::Gitlab.dev_or_test_env?}.gitlab.com"
base_url = ENV.fetch('MARKETING_SITE_URL', default_base_url)

direct :blog do
  # How to get any passed in options, like :anchor, here?
  [base_url, 'blog', anchor: '?']
end
