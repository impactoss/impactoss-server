require "rails_helper"

RSpec.describe Sdgtarget, type: :model do
  it { is_expected.to validate_presence_of :reference }
  it { is_expected.to validate_presence_of :title }

  # shoulda-matchers deprecation: not possible to fully test this
  # it { is_expected.to validate_inclusion_of(:draft).in_array([true, false]) }
end
