# frozen_string_literal: true
require 'rails_helper'
require 'json'

RSpec.describe IndicatorsController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }
    let!(:Indicator) { FactoryGirl.create(:indicator) }
    let!(:draft_indicator) { FactoryGirl.create(:indicator, draft: true) }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'all published indicators (no drafts)' do
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'guest will not see draft indicators' do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end

      it 'manager will see draft indicators' do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end
    end
  end

  describe 'Get show' do
    let(:indicator) { FactoryGirl.create(:indicator) }
    let(:draft_indicator) { FactoryGirl.create(:indicator, draft: true) }
    subject { get :show, params: { id: indicator }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the indicator' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(indicator.id)
      end

      it 'will not show draft indicator' do
        get :show, params: { id: draft_indicator }, format: :json
        expect(response).to be_not_found
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a indicator' do
        post :create, format: :json, params: { indicator: { title: 'test', description: 'test', target_date: 'today' } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:measure) { FactoryGirl.create(:measure) }
      subject do
        post :create,
             format: :json,
             params: {
               indicator: {
                 title: 'test',
                 description: 'test',
                 target_date: 'today',
                 measure_indicators_attributes: [{ measure_id: measure.id }]
               }
             }
      end

      it 'will not allow a guest to create a indicator' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a indicator' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will record what manager created the indicator', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last-modified-user-id'].to_i).to eq user.id
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { indicator: { description: 'desc only' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Put update' do
    let(:indicator) { FactoryGirl.create(:indicator) }
    subject do
      put :update,
          format: :json,
          params: { id: indicator,
                    indicator: { title: 'test update', description: 'test update', target_date: 'today update' } }
    end

    context 'when not signed in' do
      it 'not allow updating a indicator' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to update a indicator' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to update a indicator' do
        sign_in user
        expect(subject).to be_ok
      end

      it 'will record what manager updated the indicator', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last-modified-user-id'].to_i).to eq user.id
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        put :update, format: :json, params: { id: indicator, indicator: { title: '' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Delete destroy' do
    let(:indicator) { FactoryGirl.create(:indicator) }
    subject { delete :destroy, format: :json, params: { id: indicator } }

    context 'when not signed in' do
      it 'not allow deleting a indicator' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to delete a indicator' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a indicator' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
