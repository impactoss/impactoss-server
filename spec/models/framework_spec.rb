require 'rails_helper'

RSpec.describe Framework, type: :model do
  it { should validate_presence_of :title }
  it { should have_many :frameworks }
  it { should have_many :frameworks_taxonomies }
  it { should have_many :taxonomies }
  it { should have_many :recommendations }
end
