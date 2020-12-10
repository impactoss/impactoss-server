require 'rails_helper'

RSpec.describe Taxonomy, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_inclusion_of(:allow_multiple).in_array([true, false]) }
  it { is_expected.to validate_inclusion_of(:tags_measures).in_array([true, false]) }

  it { is_expected.to have_many(:categories) }
  it { is_expected.to belong_to(:framework) }
  it { is_expected.to have_many(:frameworks) }
  it { is_expected.to have_many(:framework_taxonomies) }
end
