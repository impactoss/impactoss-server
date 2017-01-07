require 'rails_helper'
require 'json'

RSpec.describe TaxonomiesController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }
    let!(:taxonomy) { FactoryGirl.create(:taxonomy) }
    let!(:draft_taxonomy) { FactoryGirl.create(:taxonomy, draft: true) }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'all published taxonomies (no drafts)' do
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'guest will not see draft taxonomies' do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end

      it 'manager will see draft taxonomies' do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end
    end
  end

  describe 'Get show' do
    let(:taxonomy) { FactoryGirl.create(:taxonomy) }
    let(:draft_taxonomy) { FactoryGirl.create(:taxonomy, draft: true) }
    subject { get :show, params: { id: taxonomy }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the taxonomy' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(taxonomy.id)
      end

      it 'will not show draft taxonomy' do
        get :show, params: { id: draft_taxonomy }, format: :json
        expect(response).to be_not_found
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a taxonomy' do
        post :create, format: :json, params: { taxonomy: { title: 'test', description: 'test', target_date: 'today' } }
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
               taxonomy: {
                 title: 'test',
                 short_title: 'bla',
                 description: 'test',
                 target_date: 'today',
                 allow_multiple: false,
                 tags_recommendations: true,
                 tags_measures: false,
                 taxonomy_id: taxonomy.id
               }
             }
      end

      it 'will not allow a guest to create a taxonomy' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a taxonomy' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will record what manager created the taxonomy', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last-modified-user-id'].to_i).to eq user.id
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { taxonomy: { description: 'desc only', taxonomy_id: 999 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Put update' do
    let(:taxonomy) { FactoryGirl.create(:taxonomy) }
    subject do
      put :update,
          format: :json,
          params: { id: taxonomy,
                    taxonomy: { title: 'test update', description: 'test update', target_date: 'today update' } }
    end

    context 'when not signed in' do
      it 'not allow updating a taxonomy' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to update a taxonomy' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to update a taxonomy' do
        sign_in user
        expect(subject).to be_ok
      end

      it 'will record what manager updated the taxonomy', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last-modified-user-id'].to_i).to eq user.id
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        put :update, format: :json, params: { id: taxonomy, taxonomy: { title: '' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Delete destroy' do
    let(:taxonomy) { FactoryGirl.create(:taxonomy) }
    subject { delete :destroy, format: :json, params: { id: taxonomy } }

    context 'when not signed in' do
      it 'not allow deleting a taxonomy' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to delete a taxonomy' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a taxonomy' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
