require 'rails_helper'

RSpec.describe Taxonomy, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_inclusion_of(:allow_multiple).in_array([true, false]) }
  it { is_expected.to validate_inclusion_of(:tags_measures).in_array([true, false]) }

  it { is_expected.to have_many(:categories) }
  it { is_expected.to belong_to(:framework).optional }
  it { is_expected.to have_many(:frameworks) }
  it { is_expected.to have_many(:framework_taxonomies) }
  it { is_expected.to belong_to(:taxonomy).optional }
  it { is_expected.to have_many :taxonomies }

  it { is_expected.to have_many(:categories) }

  context "Sub-relation validations" do

    it "Should update parent_id" do
      taxonomy = FactoryGirl.create(:taxonomy)
      sub_taxonomy = FactoryGirl.create(:taxonomy)
      sub_taxonomy.parent_id = taxonomy.id
      sub_taxonomy.save!
    end

    it "Should not update parent_id if parent is already a sub-taxonomy" do
      sub_taxonomy = FactoryGirl.create(:taxonomy)
      taxonomy = FactoryGirl.create(:taxonomy, :sub_taxonomy)
      sub_taxonomy.parent_id = taxonomy.id
      expect{sub_taxonomy.save!}.to raise_exception(/Parent taxonomy is already a sub-taxonomy./)
    end
  end
end
