require 'rails_helper'

RSpec.feature 'User can see indicator views', type: :feature do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:indicators) { FactoryGirl.create_list(:indicator, 5) }

  before(:each) do
    admin = Role.new(name: 'admin', friendly_name: 'Admin')
    admin.save!
    user.roles = [admin]
  end

  scenario 'User can log in and see index page' do
    login_as(user)
    visit indicators_path
    expect(page).to have_content('Indicators')
    expect(page).to have_content(indicators.first.title)
    expect(page).to have_content('New')
  end

  scenario 'User can log in and see show page' do
    login_as(user)
    visit indicator_path(indicators.first)
    expect(page).to have_content('Indicators')
    expect(page).to have_content(indicators.first.title)
    expect(page).to have_content(indicators.first.description)
    expect(page).to have_content('Edit')
  end

  scenario 'User can log in and see new page' do
    login_as(user)
    visit new_indicator_path(Indicator.new)
    expect(page).to have_content('Indicator')
    expect(page).to have_button('Save')
    expect(page).to have_content('Cancel')
  end

  scenario 'User can log in and see edit page' do
    login_as(user)
    visit edit_indicator_path(indicators.first)
    expect(page).to have_content('Indicators')
    expect(find_field('Title').value).to eq(indicators.first.title)
    expect(find_field('Description').value).to eq(indicators.first.description)
    expect(page).to have_button('Save')
    expect(page).to have_content('Cancel')
  end
end
