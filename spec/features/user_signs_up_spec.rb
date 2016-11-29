# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'User signs up', type: :feature do
  include FeatureSpecHelpers
  let(:user) { FactoryGirl.build(:user) }

  scenario 'User provides valid information' do
    fill_in_sign_up_form
    expect(flash?('Welcome! You have signed up successfully.')).to eq true
  end

  scenario 'User provides incomplete information' do
    fill_in_sign_up_form email: ''
    expect(flash?("Email can't be blank")).to eq true
  end

  private

  def fill_in_sign_up_form(email: user.email, password: user.password, submit: true)
    visit new_user_registration_path
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    fill_in 'Password confirmation', with: password
    click_button 'Complete Sign Up' if submit
  end
end
