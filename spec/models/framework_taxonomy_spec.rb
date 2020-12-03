require 'rails_helper'

RSpec.describe FrameworkTaxonomy, type: :model do 
  it { should belong_to :framework }
  it { should belong_to :taxonomy }
end