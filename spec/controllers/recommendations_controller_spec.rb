# frozen_string_literal: true
require 'rails_helper'
require 'json'

RSpec.describe RecommendationsController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }
    let!(:recommendation) { FactoryGirl.create(:recommendation) }
    let!(:draft_recommendation) { FactoryGirl.create(:recommendation, draft: true) }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'all published recommendations (no drafts)' do
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'guest will not see draft recommendations' do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end

      it 'manager will see draft recommendations' do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end
    end
  end

  describe 'Get show' do
    let(:recommendation) { FactoryGirl.create(:recommendation) }
    let(:draft_recommendation) { FactoryGirl.create(:recommendation, draft: true) }
    subject { get :show, params: { id: recommendation }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the recommendation' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(recommendation.id)
      end

      it 'will not show draft recommendation' do
        get :show, params: { id: draft_recommendation }, format: :json
        expect(response).to be_not_found
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a recommendation' do
        post :create, format: :json, params: { recommendation: { title: 'test', number: '1' } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      subject do
        post :create, format: :json, params: { recommendation: { title: 'test', number: '1' } }
      end

      it 'will not allow a guest to create a recommendation' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a recommendation' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { recommendation: { description: 'desc only' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Put update' do
    let(:recommendation) { FactoryGirl.create(:recommendation) }
    subject do
      put :update,
          format: :json,
          params: { id: recommendation,
                    recommendation: { title: 'test update', description: 'test update', target_date: 'today update' } }
    end

    context 'when not signed in' do
      it 'not allow updating a recommendation' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to update a recommendation' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to update a recommendation' do
        sign_in user
        expect(subject).to be_ok
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        put :update, format: :json, params: { id: recommendation, recommendation: { title: '' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Delete destroy' do
    let(:recommendation) { FactoryGirl.create(:recommendation) }
    subject { delete :destroy, format: :json, params: { id: recommendation } }

    context 'when not signed in' do
      it 'not allow deleting a recommendation' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to delete a recommendation' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a recommendation' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
