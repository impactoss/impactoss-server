require 'rails_helper'
require 'json'

RSpec.describe RecommendationMeasuresController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }
    end
  end

  describe 'Get show' do
    let(:recommendation_measure) { FactoryGirl.create(:recommendation_measure) }
    subject { get :show, params: { id: recommendation_measure }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the recommendation_measure' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(recommendation_measure.id)
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a recommendation_measure' do
        post :create, format: :json, params: { recommendation_measure: { recommendation_id: 1, measure_id: 1 } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:recommendation) { FactoryGirl.create(:recommendation) }
      let(:measure) { FactoryGirl.create(:measure) }

      subject do
        post :create,
             format: :json,
             params: {
               recommendation_measure: {
                 recommendation_id: recommendation.id,
                 measure_id: measure.id
               }
             }
      end

      it 'will not allow a guest to create a recommendation_measure' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a recommendation_measure' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { recommendation_measure: { description: 'desc only', taxonomy_id: 999 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT update' do
    let(:recommendation_measure) { FactoryGirl.create(:recommendation_measure) }
    subject do
      put :update,
          format: :json,
          params: { id: recommendation_measure,
                    recommendation_measure: { title: 'test update',
                                              description: 'test update',
                                              target_date: 'today update' } }
    end

    context 'when not signed in' do
      it 'not allow updating a recommendation_measure' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to update a recommendation_measure' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to update a recommendation_measure' do
        sign_in user
        expect(subject).to be_ok
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        put :update, format: :json, params: { id: recommendation_measure,
                                              recommendation_measure: { recommendation_id: 999 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Delete destroy' do
    let(:recommendation_measure) { FactoryGirl.create(:recommendation_measure) }
    subject { delete :destroy, format: :json, params: { id: recommendation_measure } }

    context 'when not signed in' do
      it 'not allow deleting a recommendation_measure' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to delete a recommendation_measure' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a recommendation_measure' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
