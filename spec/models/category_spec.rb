require "rails_helper"

RSpec.describe Category, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to belong_to :taxonomy }
  it { is_expected.to belong_to(:manager).optional }
  it { is_expected.to belong_to(:category).optional }
  it { is_expected.to have_many :recommendations }
  it { is_expected.to have_many :users }
  it { is_expected.to have_many :measures }
  it { is_expected.to have_many :indicators }
  it { is_expected.to have_many :progress_reports }
  it { is_expected.to have_many :due_dates }
  it { is_expected.to have_many :categories }
  it { is_expected.to have_many :children_due_dates }

  context "Sub-relation validations" do
    it "will not allow guest users to be assigned" do
      category = FactoryBot.create(:category)
      user = FactoryBot.create(:user)
      category.manager_id = user.id
      expect { category.save! }.to raise_exception(/Manager must be a manager or an admin/)
    end

    it "will not allow contributor users to be assigned" do
      category = FactoryBot.create(:category)
      user = FactoryBot.create(:user, :contributor)
      category.manager_id = user.id
      expect { category.save! }.to raise_exception(/Manager must be a manager or an admin/)
    end

    it "will allow manager users to be assigned" do
      category = FactoryBot.create(:category)
      user = FactoryBot.create(:user, :manager)
      expect {
        category.manager_id = user.id
        category.save!
      }.to change { category.reload.manager_id }.from(nil).to(user.id)
    end

    it "will allow admin users to be assigned" do
      category = FactoryBot.create(:category)
      user = FactoryBot.create(:user, :admin)
      expect {
        category.manager_id = user.id
        category.save!
      }.to change { category.reload.manager_id }.from(nil).to(user.id)
    end

    it "Should update parent_id with correct taxonomy relation" do
      category = FactoryBot.create(:category, :parent_category)
      sub_category = FactoryBot.create(:category, :sub_category)
      taxonomy = FactoryBot.create(:taxonomy, :sub_taxonomy)

      sub_category.taxonomy_id = taxonomy.id
      category.taxonomy_id = taxonomy.parent_id
      sub_category.save!
      category.save!

      sub_category.parent_id = category.id
      sub_category.save!
    end

    it "Should not update parent_id if parent is already a sub-category" do
      category = FactoryBot.create(:category)
      parent_category = FactoryBot.create(:category, :parent_category)
      sub_category = FactoryBot.create(:category, :sub_category)
      taxonomy = FactoryBot.create(:taxonomy, :sub_taxonomy)

      parent_category.taxonomy_id = taxonomy.id
      category.taxonomy_id = taxonomy.parent_id
      category.save!

      parent_category.parent_id = category.id
      parent_category.save!

      sub_category.parent_id = parent_category.id
      expect { sub_category.save! }.to raise_exception(/Parent category is already a sub-category./)
    end

    it "Should not update parent_id with incorrect taxonomy relation" do
      category = FactoryBot.create(:category, :parent_category)
      sub_category = FactoryBot.create(:category, :sub_category)
      sub_category.parent_id = category.id
      expect { sub_category.save! }.to raise_exception(/Validation failed: Parent Taxonomy does not have parent category's taxonomy as parent./)
    end
  end
end
