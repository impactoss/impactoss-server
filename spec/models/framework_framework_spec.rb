require 'rails_helper'

RSpec.describe FrameworkFramework, type: :model do 
  it { is_expected.to belong_to(:framework).with_foreign_key('framework_id')}
  it { is_expected.to belong_to(:other_framework).class_name('Framework').with_foreign_key('other_framework_id')}
end