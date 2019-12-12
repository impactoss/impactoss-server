require 'rails_helper'

RSpec.describe Taxonomy, type: :model do
  it { should validate_presence_of :title }
  it { should belong_to :taxonomy }
  it { should have_many :taxonomies }
  it { should validate_inclusion_of(:allow_multiple).in_array([true, false]) }
  it { should validate_inclusion_of(:tags_recommendations).in_array([true, false]) }
  it { should validate_inclusion_of(:tags_measures).in_array([true, false]) }

  it { should have_many(:categories) }

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
