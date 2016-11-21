# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'User signs up', type: :feature do
  let(:user) { FactoryGirl.build(:user) }

  scenario 'User provides valid information' do
    fill_in_sign_up_form
    expect(has_flash?('Welcome! You have signed up successfully.')).to eq true
  end

  scenario 'User provides incomplete information' do
    fill_in_sign_up_form email: ''
    expect(has_flash?("Email can't be blank")).to eq true
  end

  private

  def fill_in_sign_up_form(email: user.email, password: user.password, submit: true)
    visit new_user_registration_path
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    fill_in 'Password confirmation', with: password
    click_button 'Complete Sign Up' if submit
  end

  # TODO: JM candidate for moving to shared module
  def has_flash?(content)
    page.has_css?('.callout', text: content)
  end
end
