require 'rails_helper'

RSpec.describe MeasureCategory, type: :model do
  it { should belong_to :measure }
  it { should belong_to :category }
end
