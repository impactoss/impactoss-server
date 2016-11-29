# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'User logs in', type: :feature do
  include FeatureSpecHelpers
  let!(:user) { FactoryGirl.create(:user) }
  scenario 'User provides valid email and password' do
    fill_in_login_form
    expect(current_path).to eq root_path
  end

  scenario 'User provides invalid email' do
    fill_in_login_form(email: Faker::Internet.email)
    assert_login_failed
  end

  scenario 'User provides invalid password' do
    fill_in_login_form(password: 'fake password')

    assert_login_failed
  end

  private

  def assert_login_failed
    expect(current_path).to eq new_user_session_path
    expect(flash?('Invalid Email or password.'))
  end

  def fill_in_login_form(email: user.email, password: user.password, submit: true)
    visit new_user_session_path
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_button 'Log in' if submit
  end
end
