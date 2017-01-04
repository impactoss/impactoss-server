# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User, type: :model do
  subject { FactoryGirl.create(:user) }
  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'is invalid without an email' do
    subject.email = ''
    expect(subject).not_to be_valid
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
