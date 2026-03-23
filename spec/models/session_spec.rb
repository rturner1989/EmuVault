require "rails_helper"

RSpec.describe Session do
  subject(:session) { build(:session) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
