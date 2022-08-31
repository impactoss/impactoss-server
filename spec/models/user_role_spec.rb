require "rails_helper"

RSpec.describe UserRole, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :role }
  # it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:role_id) }

  context "with a user and a role" do
    let(:user) { FactoryBot.create(:user) }
    let(:role) { FactoryBot.create(:role) }

    subject { described_class.create(user: user, role: role) }

    it "create sets the relationship_updated_at on the user" do
      expect { subject }.to change { user.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the user" do
      subject
      expect { subject.touch }.to change { user.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the user" do
      expect { subject.destroy }.to change { user.reload.relationship_updated_at }
    end
  end
end
