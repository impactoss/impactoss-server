require 'rails_helper'
require 'json'

RSpec.describe CategoriesController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }
    let!(:category) { FactoryGirl.create(:category) }
    let!(:draft_category) { FactoryGirl.create(:category, draft: true) }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'all published categories (no drafts)' do
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'guest will not see draft categories' do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end

      it 'contributor will see draft categories' do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end

      it 'manager will see draft categories' do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end
    end
  end

  describe 'Get show' do
    let(:category) { FactoryGirl.create(:category) }
    let(:draft_category) { FactoryGirl.create(:category, draft: true) }
    subject { get :show, params: { id: category }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the category' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(category.id)
      end

      it 'will not show draft category' do
        get :show, params: { id: draft_category }, format: :json
        expect(response).to be_not_found
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a category' do
        post :create, format: :json, params: { category: { title: 'test', description: 'test', target_date: 'today' } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:taxonomy) { FactoryGirl.create(:taxonomy) }

      subject do
        post :create,
             format: :json,
             params: {
               category: {
                 title: 'test',
                 short_title: 'bla',
                 description: 'test',
                 target_date: 'today',
                 taxonomy_id: taxonomy.id
               }
             }
      end

      it 'will not allow a guest to create a category' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a category' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will record what manager created the category', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last-modified-user-id'].to_i).to eq user.id
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { category: { description: 'desc only', taxonomy_id: 999 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Put update' do
    let(:category) { FactoryGirl.create(:category) }
    subject do
      put :update,
          format: :json,
          params: { id: category,
                    category: { title: 'test update', description: 'test update', target_date: 'today update' } }
    end

    context 'when not signed in' do
      it 'not allow updating a category' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to update a category' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to update a category' do
        sign_in user
        expect(subject).to be_ok
      end

      it 'will record what manager updated the category', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last-modified-user-id'].to_i).to eq user.id
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        put :update, format: :json, params: { id: category, category: { taxonomy_id: 999 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Delete destroy' do
    let(:category) { FactoryGirl.create(:category) }
    subject { delete :destroy, format: :json, params: { id: category } }

    context 'when not signed in' do
      it 'not allow deleting a category' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to delete a category' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a category' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
