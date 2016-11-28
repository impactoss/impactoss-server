# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'User resets password', type: :feature do
  include FeatureSpecHelpers
  let!(:user) { FactoryGirl.create(:user) }

  scenario 'User provides valid email' do
    visit new_user_password_path
    fill_in 'Email', with: user.email
    click_button 'Send me reset password instructions'
    expect(current_path).to eq new_user_session_path
    expect(flash?('You will receive an email with instructions on how to reset your password in a few minutes.'))
  end

  scenario 'User provides invalid email' do
    visit new_user_password_path
    fill_in 'Email', with: Faker::Internet.email
    click_button 'Send me reset password instructions'
    expect(flash?('Email not found'))
  end

  scenario 'User changes password with a valid reset password token' do
    reset_password_token = user.send_reset_password_instructions
    visit edit_user_password_path(reset_password_token: reset_password_token)
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: user.password
    click_button 'Change my password'
    expect(flash?('Your password has been changed successfully. You are now signed in.')).to be true
  end

  scenario 'User changes password with an invalid/consumed reset password token' do
    visit edit_user_password_path(reset_password_token: 'abc')
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: user.password
    click_button 'Change my password'
    expect(flash?('Reset password token is invalid')).to be true
  end
end
