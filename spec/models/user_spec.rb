# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User, type: :model do
  subject { FactoryGirl.create(:user) }
  it { should validate_presence_of :name }
  it { should validate_presence_of :email }
  it { should have_many :roles }
  it { should have_many :managed_categories }
  it { should have_many :categories }
  it { should have_many :managed_indicators }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'is invalid without a matching password' do
    subject.assign_attributes(
      password: 'abc123',
      password_confirmation: 'abc'
    )

    expect(subject).not_to be_valid
  end

  it 'should accept a role' do
    expect(subject.role?('the_role')).to be false

    subject.roles << Role.new(name: 'the_role', friendly_name: 'bla')

    expect(subject.role?('the_role')).to be true
  end
end
