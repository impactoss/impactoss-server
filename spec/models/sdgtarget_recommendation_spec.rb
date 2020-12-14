require 'rails_helper'

RSpec.describe SdgtargetRecommendation, type: :model do
  it { is_expected.to belong_to :sdgtarget }
  it { is_expected.to belong_to :recommendation }
  it { is_expected.to validate_uniqueness_of(:recommendation_id).scoped_to(:sdgtarget_id) }
  it { is_expected.to validate_presence_of :recommendation_id }
  it { is_expected.to validate_presence_of :sdgtarget_id }
end
