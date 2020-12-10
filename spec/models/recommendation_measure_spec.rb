require 'rails_helper'

RSpec.describe RecommendationMeasure, type: :model do
  it { is_expected.to belong_to :recommendation }
  it { is_expected.to belong_to :measure }
  it { is_expected.to validate_uniqueness_of(:measure_id).scoped_to(:recommendation_id) }
  it { is_expected.to validate_presence_of(:recommendation_id) }
  it { is_expected.to validate_presence_of(:measure_id) }
end
