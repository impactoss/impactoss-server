require 'rails_helper'

RSpec.describe MeasureIndicator, type: :model do
  it { should belong_to :measure }
  it { should belong_to :indicator }
  it { should validate_uniqueness_of(:measure_id).scoped_to(:indicator_id) }
end
