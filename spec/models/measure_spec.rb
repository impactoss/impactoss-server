require 'rails_helper'

RSpec.describe Measure, type: :model do
  before { @measure = FactoryGirl.create(:measure) }

  it 'remembers title' do
    expect(!@measure.title.empty?)
  end

  it 'enforces required fields' do
    @measure = Measure.new
    expect { @measure.save! }.to raise_error ActiveRecord::RecordInvalid

    @measure.title = 'Test'
    expect { @measure.save! }.not_to raise_error
  end

  pending 'measures must belong to a recommendation'
end
