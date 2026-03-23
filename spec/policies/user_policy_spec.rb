require "rails_helper"

RSpec.describe UserPolicy do
  let(:user) { create(:user) }
  let(:policy) { described_class.new(user, user: user) }

  %i[mark_all_read? review? confirm? resolve?].each do |action|
    describe "##{action}" do
      it "permits any authenticated user" do
        expect(policy.public_send(action)).to be(true)
      end
    end
  end
end
