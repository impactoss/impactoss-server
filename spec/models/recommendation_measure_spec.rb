require 'rails_helper'

RSpec.describe RecommendationMeasure, type: :model do
  it { should belong_to :recommendation }
  it { should belong_to :measure }
  it { should validate_uniqueness_of(:measure_id).scoped_to(:recommendation_id) }
end
