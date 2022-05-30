# frozen_string_literal: true

module PasswordComplexityHelper
  # Returns a random password which will always meet complexity
  # requirements
  # See also https://www.rubydoc.info/github/plataformatec/devise/Devise.friendly_token
  def random_complex_password
    # First, a failsafe
    raise "This must be used in tests only!" unless Rails.env.test?

    # Second, a cryptographically secure password that also includes
    # a symbol, number, lowercase, uppercase
    "#{::Devise.friendly_token}_1aA"
  end
end
