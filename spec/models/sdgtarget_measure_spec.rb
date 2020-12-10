require 'rails_helper'

RSpec.describe SdgtargetMeasure, type: :model do
  it { is_expected.to belong_to :sdgtarget }
  it { is_expected.to belong_to :measure }
  it { is_expected.to validate_uniqueness_of(:measure_id).scoped_to(:sdgtarget_id) }
  it { is_expected.to validate_presence_of :measure_id }
  it { is_expected.to validate_presence_of :sdgtarget_id }
end
