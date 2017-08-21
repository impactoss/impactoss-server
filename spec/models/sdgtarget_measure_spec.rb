require 'rails_helper'

RSpec.describe SdgtargetMeasure, type: :model do
  it { should belong_to :sdgtarget }
  it { should belong_to :measure }
  it { should validate_uniqueness_of(:measure_id).scoped_to(:sdgtarget_id) }
  it { should validate_presence_of :measure_id }
  it { should validate_presence_of :sdgtarget_id }
end
