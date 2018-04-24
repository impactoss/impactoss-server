require 'rails_helper'
require 'json'

RSpec.describe PagesController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }
    let!(:page) { FactoryGirl.create(:page) }
    let!(:draft_page) { FactoryGirl.create(:page, draft: true) }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'all published pages (no drafts)' do
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'guest will not see draft pages' do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end

      it 'contributor will see draft pages' do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end

      it 'manager will see draft pages' do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end
    end
  end

  describe 'Get show' do
    let(:page) { FactoryGirl.create(:page) }
    let(:draft_page) { FactoryGirl.create(:page, draft: true) }
    subject { get :show, params: { id: page }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the page' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(page.id)
      end

      it 'will not show draft page' do
        get :show, params: { id: draft_page }, format: :json
        expect(response).to be_not_found
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a page' do
        post :create, format: :json, params: { page: { title: 'test', description: 'test', target_date: 'today' } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:admin) { FactoryGirl.create(:user, :admin) }
      let(:taxonomy) { FactoryGirl.create(:taxonomy) }

      subject do
        post :create,
             format: :json,
             params: {
               page: {
                 title: 'test',
                 content: 'bla',
                 menu_title: 'test'
               }
             }
      end

      it 'will not allow a guest to create a page' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a manager to create a page' do
        sign_in user
        expect(subject).to be_forbidden
      end

      it 'will not allow an admin to create a page' do
        sign_in admin
        expect(subject).to be_created
      end

      it 'will record what manager created the page', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last_modified_user_id'].to_i).to eq admin.id
      end

      it 'will return an error if params are incorrect' do
        sign_in admin
        post :create, format: :json, params: { page: { description: 'desc only', taxonomy_id: 999 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT update' do
    let(:page) { FactoryGirl.create(:page) }
    subject do
      put :update,
          format: :json,
          params: { id: page,
                    page: { title: 'test update', description: 'test update', target_date: 'today update' } }
    end

    context 'when not signed in' do
      it 'not allow updating a page' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:admin) { FactoryGirl.create(:user, :admin) }

      it 'will not allow a guest to update a page' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a manager to update a page' do
        sign_in user
        expect(subject).to be_forbidden
      end

      it 'will allow an admin to update a page' do
        sign_in admin
        expect(subject).to be_ok
      end

      it 'will reject and update where the last_updated_at is older than updated_at in the database' do
        sign_in admin
        page_get = get :show, params: { id: page }, format: :json
        json = JSON.parse(page_get.body)
        current_update_at = json['data']['attributes']['updated_at']

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
                        format: :json,
                        params: { id: page,
                                  page: { title: 'test update', description: 'test updateeee', target_date: 'today update', updated_at: current_update_at } }
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
                        format: :json,
                        params: { id: page,
                                  page: { title: 'test update', description: 'test updatebbbb', target_date: 'today update', updated_at: current_update_at } }
          expect(subject).to_not be_ok
        end
      end

      it 'will record what manager updated the page', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last_modified_user_id'].to_i).to eq admin.id
      end

      it 'will return the latest last_modified_user_id', versioning: true do
        expect(PaperTrail).to be_enabled
        page.versions.first.update_column(:whodunnit, user.id)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last_modified_user_id'].to_i).to eq(admin.id)
      end
    end
  end

  describe 'Delete destroy' do
    let(:page) { FactoryGirl.create(:page) }
    subject { delete :destroy, format: :json, params: { id: page } }

    context 'when not signed in' do
      it 'not allow deleting a page' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:admin) { FactoryGirl.create(:user, :admin) }

      it 'will not allow a guest to delete a page' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a manager to delete a page' do
        sign_in user
        expect(subject).to be_forbidden
      end

      it 'will allow an admin to delete a page' do
        sign_in admin
        expect(subject).to be_no_content
      end
    end
  end
end
