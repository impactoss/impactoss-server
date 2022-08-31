require "rails_helper"

RSpec.describe UserCategory, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :category }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:category_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:category_id) }

  context "with a user and a category" do
    let(:user) { FactoryBot.create(:user) }
    let(:category) { FactoryBot.create(:category) }

    subject { described_class.create(user: user, category: category) }

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
