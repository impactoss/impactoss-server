require 'rails_helper'

RSpec.describe MeasureIndicator, type: :model do
  it { is_expected.to belong_to :measure }
  it { is_expected.to belong_to :indicator }
  it { is_expected.to validate_uniqueness_of(:measure_id).scoped_to(:indicator_id) }
  it { is_expected.to validate_presence_of(:measure_id) }
  it { is_expected.to validate_presence_of(:indicator_id) }
end
