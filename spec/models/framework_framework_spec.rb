require 'rails_helper'

RSpec.describe FrameworkFramework, type: :model do 
  it { should belong_to(:framework).class_name('Framework').with_foreign_key('framework_id')}
  it { should belong_to(:other_framework).class_name('Framework').with_foreign_key('other_framework_id')}
end