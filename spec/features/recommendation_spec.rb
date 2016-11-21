require "rails_helper"

RSpec.feature "User can see recommendation views", type: :feature do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:recommendations) { FactoryGirl.create_list(:recommendation, 5) }

    scenario "User can log in and see index page" do
      login_as(user)
      visit recommendations_path
      expect(page).to have_content("Recommendations")
      expect(page).to have_content(recommendations.first.title)
      expect(page).to have_content(recommendations.first.number)
      expect(page).to have_content("New")
    end

    scenario "User can log in and see show page" do
      login_as(user)
      visit recommendation_path(recommendations.first)
      expect(page).to have_content("Recommendations")
      expect(page).to have_content(recommendations.first.title)
      expect(page).to have_content(recommendations.first.number)
      expect(page).to have_content("Edit")
    end

    scenario "User can log in and see new page" do
      login_as(user)
      visit new_recommendation_path(Recommendation.first)
      expect(page).to have_content("Recommendations")
      expect(page).to have_button("Save")
      expect(page).to have_content("Cancel")
    end

    scenario "User can log in and see edit page" do
      login_as(user)
      visit edit_recommendation_path(recommendations.first)
      expect(page).to have_content("Recommendations")
      expect(find_field('Title').value).to eq(recommendations.first.title)
      expect(find_field('NO').value).to eq(recommendations.first.number.to_s)
      expect(page).to have_button("Save")
      expect(page).to have_content("Cancel")
    end

end
