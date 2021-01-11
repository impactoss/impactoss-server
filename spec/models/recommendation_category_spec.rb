require 'rails_helper'

RSpec.describe RecommendationCategory, type: :model do
  it { is_expected.to belong_to :recommendation }
  it { is_expected.to belong_to :category }
  it { is_expected.to validate_uniqueness_of(:category_id).scoped_to(:recommendation_id) }
  it { is_expected.to validate_presence_of(:recommendation_id) }
  it { is_expected.to validate_presence_of(:category_id) }
end
