require 'rails_helper'

RSpec.describe RecommendationCategory, type: :model do
  it { should belong_to :recommendation }
  it { should belong_to :category }
  it { should validate_uniqueness_of(:category_id).scoped_to(:recommendation_id) }
end
