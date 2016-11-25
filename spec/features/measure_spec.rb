require 'rails_helper'

RSpec.feature 'User can see measures views', type: :feature do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:measures) { FactoryGirl.create_list(:measure, 5) }

  before(:each) do
    admin = Role.new(name: 'admin', friendly_name: 'Admin')
    admin.save!
    user.roles = [admin]
  end

  scenario 'User can log in and see index page' do
    login_as(user)
    visit measures_path
    expect(page).to have_content('Actions')
    expect(page).to have_content(measures.first.title)

    expect(page).to have_content('New')
  end

  scenario 'User can log in and see show page' do
    login_as(user)
    visit measure_path(measures.first)
    expect(page).to have_content('Actions')
    expect(page).to have_content(measures.first.title)
    expect(page).to have_content(measures.first.description)
    expect(page).to have_content('Edit')
  end

  scenario 'User can log in and see new page' do
    login_as(user)
    visit new_measure_path(Measure.new)
    expect(page).to have_content('Actions')
    expect(page).to have_button('Save')
    expect(page).to have_content('Cancel')
  end

  scenario 'User can log in and see edit page' do
    login_as(user)
    visit edit_measure_path(measures.first)
    expect(page).to have_content('Actions')
    expect(find_field('Title').value).to eq(measures.first.title)
    expect(find_field('Description').value).to eq(measures.first.description)
    expect(page).to have_button('Save')
    expect(page).to have_content('Cancel')
  end

  scenario 'User can go to new page and create a new action' do
    login_as(user)
    visit measures_path
    click_link 'New'
    expect(page).to have_content 'Action'
  end

  scenario 'User can create a new action' do
    login_as(user)
    visit new_measure_path(Measure.new)

    fill_in 'Title', with: 'test title'
    fill_in 'Description', with: 'test description'

    click_button 'Save'

    expect(page).to have_content 'test title'
    expect(page).to have_content 'test description'
  end
end
