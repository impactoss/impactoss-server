require 'rails_helper'
require 'json'

RSpec.describe SdgtargetCategoriesController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }
    end
  end

  describe 'Get show' do
    let(:sdgtarget_category) { FactoryGirl.create(:sdgtarget_category) }
    subject { get :show, params: { id: sdgtarget_category }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the sdgtarget_category' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(sdgtarget_category.id)
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a sdgtarget_category' do
        post :create, format: :json, params: { sdgtarget_category: { sdgtarget_id: 1, category_id: 1 } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:sdgtarget) { FactoryGirl.create(:sdgtarget) }
      let(:category) { FactoryGirl.create(:category) }

      subject do
        post :create,
             format: :json,
             params: {
               sdgtarget_category: {
                 sdgtarget_id: sdgtarget.id,
                 category_id: category.id
               }
             }
      end

      it 'will not allow a guest to create a sdgtarget_category' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to create a sdgtarget_category' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a sdgtarget_category' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { sdgtarget_category: { description: 'desc only', taxonomy_id: 999 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Delete destroy' do
    let(:sdgtarget_category) { FactoryGirl.create(:sdgtarget_category) }
    subject { delete :destroy, format: :json, params: { id: sdgtarget_category } }

    context 'when not signed in' do
      it 'not allow deleting a sdgtarget_category' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'will not allow a guest to delete a sdgtarget_category' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to delete a sdgtarget_category' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a sdgtarget_category' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
