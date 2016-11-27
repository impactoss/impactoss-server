require 'rails_helper'

RSpec.describe Indicator, type: :model do
  before { @indicator = FactoryGirl.create(:indicator) }

  it 'remembers title' do
    expect(!@indicator.title.empty?)
  end

  it 'enforces required fields' do
    @indicator = Indicator.new
    expect { @indicator.save! }.to raise_error ActiveRecord::RecordInvalid

    @indicator.title = 'Test'
    expect { @indicator.save! }.not_to raise_error
  end

  pending 'indicators must belong to at least one measure'
end
