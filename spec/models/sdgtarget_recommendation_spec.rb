require 'rails_helper'

RSpec.describe SdgtargetRecommendation, type: :model do
  it { should belong_to :sdgtarget }
  it { should belong_to :recommendation }
  it { should validate_uniqueness_of(:recommendation_id).scoped_to(:sdgtarget_id) }
  it { should validate_presence_of :recommendation_id }
  it { should validate_presence_of :sdgtarget_id }
end
