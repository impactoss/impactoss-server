require 'rails_helper'
require 'json'

RSpec.describe MeasureIndicatorsController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }
    end
  end

  describe 'Get show' do
    let(:measure_indicator) { FactoryGirl.create(:measure_indicator) }
    subject { get :show, params: { id: measure_indicator }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the measure_indicator' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(measure_indicator.id)
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a measure_indicator' do
        post :create, format: :json, params: { measure_indicator: { measure_id: 1, indicator_id: 1 } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:measure) { FactoryGirl.create(:measure) }
      let(:indicator) { FactoryGirl.create(:indicator) }

      subject do
        post :create,
             format: :json,
             params: {
               measure_indicator: {
                 measure_id: measure.id,
                 indicator_id: indicator.id
               }
             }
      end

      it 'will not allow a guest to create a measure_indicator' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to create a measure_indicator' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a measure_indicator' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { measure_indicator: { description: 'desc only', taxonomy_id: 999 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Delete destroy' do
    let(:measure_indicator) { FactoryGirl.create(:measure_indicator) }
    subject { delete :destroy, format: :json, params: { id: measure_indicator } }

    context 'when not signed in' do
      it 'not allow deleting a measure_indicator' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'will not allow a guest to delete a measure_indicator' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to delete a measure_indicator' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a measure_indicator' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
