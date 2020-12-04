require 'rails_helper'

RSpec.describe RecommendationIndicator, type: :model do
  it { should belong_to :recommendation }
  it { should belong_to :indicator }
  it { should validate_presence_of(:recommendation_id) }
  it { should validate_presence_of(:indicator_id) }
end
