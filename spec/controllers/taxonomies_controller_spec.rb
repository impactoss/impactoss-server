require 'rails_helper'
require 'json'

RSpec.describe TaxonomiesController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }
    let!(:taxonomy) { FactoryGirl.create(:taxonomy) }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'all published taxonomies' do
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end
    end
  end

  describe 'Get show' do
    let(:taxonomy) { FactoryGirl.create(:taxonomy) }
    subject { get :show, params: { id: taxonomy }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the taxonomy' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(taxonomy.id)
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
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
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
                 tags_measures: false,
                 taxonomy_id: taxonomy.id
               }
             }
      end

      it 'will not allow a guest to create a taxonomy' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to create a taxonomy' do
        sign_in user
        expect(subject).to be_forbidden
      end

      it 'will not allow a manager to create a taxonomy' do
        sign_in user
        expect(subject).to be_forbidden
      end
    end
  end

  describe 'PUT update' do
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
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to update a taxonomy' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to update a taxonomy' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will not allow a manager to update a taxonomy' do
        sign_in user
        expect(subject).to be_forbidden
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
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'will not allow a guest to delete a taxonomy' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to delete a taxonomy' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will not allow a manager to delete a taxonomy' do
        sign_in user
        expect(subject).to be_forbidden
      end
    end
  end
end
