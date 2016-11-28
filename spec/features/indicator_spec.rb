require 'rails_helper'

RSpec.feature 'Indicators', type: :feature do
  let(:admin) { FactoryGirl.create(:user, :admin) }
  let(:manager) { FactoryGirl.create(:user, :manager) }
  let(:reporter) { FactoryGirl.create(:user, :reporter) }
  let(:user) { FactoryGirl.create(:user) }

  let!(:indicators) { FactoryGirl.create_list(:indicator, 5) }
  let(:indicator) { FactoryGirl.create(:indicator) }
  let(:our_user) { false }
  before { login_as(our_user) if our_user }

  shared_examples 'not_authorized' do
    it { expect(page).to have_content('You are not authorized to perform this action') }
  end
  shared_examples 'need_to_sign_in' do
    it { expect(page).to have_content('You need to sign in or sign up before continuing') }
  end

  describe 'index page' do
    before { visit indicators_path }
    def expect_index_page
      expect(page).to have_content('Indicators')
      expect(page).to have_content(indicators.first.title)
    end

    context 'when logged in as admin' do
      let(:our_user) { admin }
      it { expect_index_page }
      it { expect(page).to have_content('New') }
    end
    context 'when logged in as manager' do
      let(:our_user) { manager }
      it { expect_index_page }
      it { expect(page).to have_content('New') }
    end

    context 'when logged in as reporter' do
      let(:our_user) { reporter }
      it { expect_index_page }
      it { expect(page).to have_link('New', href: new_indicator_path) }
    end

    context 'when logged with no roles' do
      let(:our_user) { user }
      it { expect(page).not_to have_link('New', href: new_indicator_path) }
    end

    context 'anonymous' do
      it { expect(page).not_to have_link('New', href: new_indicator_path) }
      it { expect(page).not_to have_content('Indicators') }
      it { expect(page).not_to have_content(indicators.first.title) }
      it { expect(page).not_to have_link('New', href: new_indicator_path) }
      include_examples 'need_to_sign_in'
    end
  end

  describe 'show' do
    before { visit indicator_path(indicators.first) }
    shared_examples 'show_page' do
      it { expect(page).to have_content('Indicators') }
      it { expect(page).to have_content(indicators.first.title) }
      it { expect(page).to have_content(indicators.first.description) }
    end
    context 'when logged in as admin' do
      let(:our_user) { admin }
      include_examples 'show_page'
      it { expect(page).to have_link('Edit', href: edit_indicator_path(indicators.first)) }
    end
    context 'when logged in as manager' do
      let(:our_user) { manager }
      include_examples 'show_page'
      it { expect(page).to have_link('Edit', href: edit_indicator_path(indicators.first)) }
    end

    context 'when logged in as reporter' do
      let(:our_user) { reporter }
      include_examples 'show_page'
      it { expect(page).to have_link('Edit', href: edit_indicator_path(indicators.first)) }
    end

    context 'when logged with no roles' do
      let(:our_user) { user }
      include_examples 'show_page'
      it { expect(page).not_to have_link('Edit', href: edit_indicator_path(indicators.first)) }
    end

    context 'anonymous' do
      it { expect(page).not_to have_content('Indicators') }
      it { expect(page).not_to have_content(indicators.first.title) }
      it { expect(page).not_to have_content(indicators.first.description) }
      it { expect(page).not_to have_link('Edit', href: edit_indicator_path(indicators.first)) }
      it { expect(page).to have_content('You need to sign in or sign up before continuing') }
    end
  end

  describe 'new' do
    shared_examples 'new_page' do
      it { expect(page).to have_content('Indicator') }
      it { expect(page).to have_button('Save') }
      it { expect(page).to have_content('Cancel') }
    end
    before { visit edit_indicator_path(indicator) }
    context 'when logged in as admin' do
      let(:our_user) { admin }
      include_examples 'new_page'
    end
    context 'when logged in as manager' do
      let(:our_user) { manager }
      include_examples 'new_page'
    end

    context 'when logged in as reporter' do
      let(:our_user) { reporter }
      include_examples 'new_page'
    end

    context 'when logged with no roles' do
      let(:our_user) { user }
      include_examples 'not_authorized'
    end

    context 'anonymous' do
      include_examples 'need_to_sign_in'
    end
  end

  describe 'create' do
    before do
      visit new_indicator_path
      fill_in 'Title', with: 'title of awesome'
      click_button 'Save'
    end
    shared_examples 'indicator_created' do
      it { expect(Indicator.last.title).to eq 'title of awesome' }
      it { expect(page).to have_content('Indicator created') }
    end
    context 'when logged in as admin' do
      let(:our_user) { admin }
      include_examples 'indicator_created'
    end
    context 'when logged in as manager' do
      let(:our_user) { manager }
      include_examples 'indicator_created'
    end
    context 'when logged in as reporter' do
      let(:our_user) { reporter }
      include_examples 'indicator_created'
    end
    pending 'when logged in but has no roles' do
      let(:our_user) { user }
      include_examples 'not_authorized'
    end
    pending 'anonymous' do
      include_examples 'need_to_sign_in'
    end
  end

  describe 'edit' do
    before { visit edit_indicator_path(indicator) }
    shared_examples 'edit_page' do
      it { expect(page).to have_content('Indicators') }
      it { expect(find_field('Title').value).to eq(indicator.title) }
      it { expect(find_field('Description').value).to eq(indicator.description) }
      it { expect(page).to have_button('Save') }
      it { expect(page).to have_link('Cancel') }
    end
    context 'when logged in as admin' do
      let(:our_user) { admin }
      include_examples 'edit_page'
    end
    context 'when logged in as manager' do
      let(:our_user) { manager }
      include_examples 'edit_page'
    end
    context 'when logged in as reporter' do
      let(:our_user) { reporter }
      include_examples 'edit_page'
    end
    context 'when logged with no roles' do
      let(:our_user) { user }
      include_examples 'not_authorized'
    end

    context 'anonymous' do
      include_examples 'need_to_sign_in'
    end
  end
  pending 'update'
end
