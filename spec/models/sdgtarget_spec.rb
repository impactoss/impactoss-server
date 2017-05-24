require 'rails_helper'

RSpec.describe Sdgtarget, type: :model do
  it { should validate_presence_of :reference }
  it { should validate_presence_of :title }

  it { should validate_inclusion_of(:draft).in_array([true, false]) }
end
