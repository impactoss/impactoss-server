require 'rails_helper'

RSpec.describe Framework, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to have_many :frameworks }
  it { is_expected.to have_many :framework_taxonomies }
  it { is_expected.to have_many :taxonomies }
  it { is_expected.to have_many :recommendations }
  it { is_expected.to have_many :framework_frameworks }
end
