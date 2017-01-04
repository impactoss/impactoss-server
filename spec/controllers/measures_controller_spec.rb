# frozen_string_literal: true
require 'rails_helper'
require 'json'

RSpec.describe MeasuresController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }
    let!(:measure) { FactoryGirl.create(:measure) }
    let!(:draft_measure) { FactoryGirl.create(:measure, draft: true) }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'all published measures (no drafts)' do
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'guest will not see draft measures' do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end

      it 'manager will see draft measures' do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end
    end
  end

  describe 'Get show' do
    let(:measure) { FactoryGirl.create(:measure) }
    let(:draft_measure) { FactoryGirl.create(:measure, draft: true) }
    subject { get :show, params: { id: measure }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the measure' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(measure.id)
      end

      it 'will not show draft measure' do
        get :show, params: { id: draft_measure }, format: :json
        expect(response).to be_not_found
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a measure' do
        post :create, format: :json, params: { measure: { title: 'test', description: 'test', target_date: 'today' } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      subject do
        post :create, format: :json, params: { measure: { title: 'test', description: 'test', target_date: 'today' } }
      end

      it 'will not allow a guest to create a measure' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a measure' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { measure: { description: 'desc only' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Put update' do
    let(:measure) { FactoryGirl.create(:measure) }
    subject do
      put :update,
          format: :json,
          params: { id: measure,
                    measure: { title: 'test update', description: 'test update', target_date: 'today update' } }
    end

    context 'when not signed in' do
      it 'not allow updating a measure' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to update a measure' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to update a measure' do
        sign_in user
        expect(subject).to be_ok
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        put :update, format: :json, params: { id: measure, measure: { title: '' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Delete destroy' do
    let(:measure) { FactoryGirl.create(:measure) }
    subject { delete :destroy, format: :json, params: { id: measure } }

    context 'when not signed in' do
      it 'not allow deleting a measure' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to delete a measure' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a measure' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
