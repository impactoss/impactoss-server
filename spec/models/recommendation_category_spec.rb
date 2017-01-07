require 'rails_helper'

RSpec.describe RecommendationCategory, type: :model do
  it { should belong_to :recommendation }
  it { should belong_to :category }
end
