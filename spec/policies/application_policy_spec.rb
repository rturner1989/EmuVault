require "rails_helper"

RSpec.describe ApplicationPolicy do
  let(:user) { create(:user) }

  %i[index? show? new? create? edit? update? destroy?].each do |action|
    describe "##{action}" do
      it "permits any authenticated user" do
        policy = described_class.new(user, user: user)

        expect(policy.public_send(action)).to be(true)
      end
    end
  end
end
