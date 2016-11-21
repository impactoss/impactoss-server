require "rails_helper"

RSpec.feature "User can see actions views", type: :feature do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:actions) { FactoryGirl.create_list(:action, 5) }

  before(:each) do
    admin = Role.new(name: "admin", friendly_name: "Admin")
    admin.save!
    user.roles = [admin]
  end

  scenario "User can log in and see index page" do
    login_as(user)
    visit actions_path
    expect(page).to have_content("Actions")
    expect(page).to have_content(actions.first.title)
    expect(page).to have_content(actions.first.description)
    expect(page).to have_content("New")
  end

  scenario "User can log in and see show page" do
    login_as(user)
    visit action_path(actions.first)
    expect(page).to have_content("Actions")
    expect(page).to have_content(actions.first.title)
    expect(page).to have_content(actions.first.description)
    expect(page).to have_content("Edit")
  end

  scenario "User can log in and see new page" do
    login_as(user)
    visit new_action_path(Action.new)
    expect(page).to have_content("Actions")
    expect(page).to have_button("Save")
    expect(page).to have_content("Cancel")
  end

  scenario "User can log in and see edit page" do
    login_as(user)
    visit edit_action_path(actions.first)
    expect(page).to have_content("Actions")
    expect(find_field("Title").value).to eq(actions.first.title)
    expect(find_field("Description").value).to eq(actions.first.description)
    expect(page).to have_button("Save")
    expect(page).to have_content("Cancel")
  end
end
