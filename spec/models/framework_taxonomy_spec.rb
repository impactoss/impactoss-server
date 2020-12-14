require 'rails_helper'

RSpec.describe FrameworkTaxonomy, type: :model do 
  it { is_expected.to belong_to :framework }
  it { is_expected.to belong_to :taxonomy }
end