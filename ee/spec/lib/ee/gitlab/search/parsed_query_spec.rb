# frozen_string_literal: true

require "fast_spec_helper"

RSpec.describe EE::Gitlab::Search::ParsedQuery do
  describe "wildcard regex" do
    subject(:regex) { EE::Gitlab::Search::ParsedQuery::WILDCARD_PREFIX_REGEX }

    it "matches leading wildcard prefixes" do
      expect("*.rb".gsub(regex, "")).to eq(".rb")
      expect("***.rb".gsub(regex, "")).to eq(".rb")
      expect("*foo.rb".gsub(regex, "")).to eq("foo.rb")
      expect("**foo.rb*".gsub(regex, "")).to eq("foo.rb*")
      expect("**.dot.dot.rb".gsub(regex, "")).to eq(".dot.dot.rb")
    end
  end
end
