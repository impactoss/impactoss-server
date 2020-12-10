require 'rails_helper'

RSpec.describe RecommendationIndicator, type: :model do
  it { is_expected.to belong_to :recommendation }
  it { is_expected.to belong_to :indicator }
  it { is_expected.to validate_presence_of(:recommendation_id) }
  it { is_expected.to validate_presence_of(:indicator_id) }
end
