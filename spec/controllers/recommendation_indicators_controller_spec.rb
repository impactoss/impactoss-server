require 'rails_helper'
require 'json'

RSpec.describe RecommendationIndicatorsController, type: :controller do
  describe 'index' do
    subject { get :index, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }
    end
  end

  describe 'show' do
    let(:recommendation_indicator) { FactoryGirl.create(:recommendation_indicator) }
    subject { get :show, params: { id: recommendation_indicator }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'returns the recommendation_indicator' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(recommendation_indicator.id)
      end
    end
  end

  describe 'create' do
    context 'when not signed in' do
      it 'doesnt allow creating a recommendation_indicator' do
        post :create, format: :json, params: { recommendation_indicator: { recommendation_id: 1, indicator_id: 1 } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:manager) { FactoryGirl.create(:user, :manager) }
      let(:admin) { FactoryGirl.create(:user, :admin) }
      let(:recommendation) { FactoryGirl.create(:recommendation) }
      let(:indicator) { FactoryGirl.create(:indicator) }

      subject do
        post :create,
             format: :json,
             params: {
               recommendation_indicator: {
                 recommendation_id: recommendation.id,
                 indicator_id: indicator.id
               }
             }
      end

      it 'wont allow a guest to create a recommendation_indicator' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'wont allow a contributor to create a recommendation_indicator' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a recommendation_indicator' do
        sign_in manager
        expect(subject).to be_created
      end

      it 'will allow an admin to create a recommendation_indicator' do
        sign_in admin
        expect(subject).to be_created
      end

      it 'will return an error if params are incorrect' do
        sign_in manager
        post :create, format: :json, params: { recommendation_indicator: { description: 'desc' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'destroy' do
    let(:recommendation_indicator) { FactoryGirl.create(:recommendation_indicator) }
    subject { delete :destroy, format: :json, params: { id: recommendation_indicator } }

    context 'when not signed in' do
      it 'wont allow deleting a recommendation_indicator' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:manager) { FactoryGirl.create(:user, :manager) }
      let(:admin) { FactoryGirl.create(:user, :admin) }

      it 'wont allow a guest to delete a recommendation_indicator' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'wont allow a contributor to delete a recommendation_indicator' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a recommendation_indicator' do
        sign_in manager
        expect(subject).to be_no_content
      end

      it 'will allow an admin to delete a recommendation_indicator' do
        sign_in admin
        expect(subject).to be_no_content
      end
    end
  end
end
