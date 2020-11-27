require 'rails_helper'

RSpec.describe Taxonomy, type: :model do
  it { should validate_presence_of :title }
  it { should validate_inclusion_of(:allow_multiple).in_array([true, false]) }
  it { should validate_inclusion_of(:tags_measures).in_array([true, false]) }

  it { should have_many(:categories) }
end
