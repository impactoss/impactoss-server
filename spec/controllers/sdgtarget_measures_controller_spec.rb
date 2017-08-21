require 'rails_helper'
require 'json'

RSpec.describe SdgtargetMeasuresController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }
    end
  end

  describe 'Get show' do
    let(:sdgtarget_measure) { FactoryGirl.create(:sdgtarget_measure) }
    subject { get :show, params: { id: sdgtarget_measure }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the sdgtarget_measure' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(sdgtarget_measure.id)
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a sdgtarget_measure' do
        post :create, format: :json, params: { sdgtarget_measure: { sdgtarget_id: 1, measure_id: 1 } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:sdgtarget) { FactoryGirl.create(:sdgtarget) }
      let(:measure) { FactoryGirl.create(:measure) }

      subject do
        post :create,
             format: :json,
             params: {
               sdgtarget_measure: {
                 sdgtarget_id: sdgtarget.id,
                 measure_id: measure.id
               }
             }
      end

      it 'will not allow a guest to create a sdgtarget_measure' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to create a sdgtarget_measure' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a sdgtarget_measure' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { sdgtarget_measure: { description: 'desc only', taxonomy_id: 999 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Delete destroy' do
    let(:sdgtarget_measure) { FactoryGirl.create(:sdgtarget_measure) }
    subject { delete :destroy, format: :json, params: { id: sdgtarget_measure } }

    context 'when not signed in' do
      it 'not allow deleting a sdgtarget_measure' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'will not allow a guest to delete a sdgtarget_measure' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to delete a sdgtarget_measure' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a sdgtarget_measure' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
