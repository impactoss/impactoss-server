# frozen_string_literal: true
require 'rails_helper'
require 'json'

RSpec.describe SdgtargetsController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }
    let!(:sdgtarget) { FactoryGirl.create(:sdgtarget) }
    let!(:draft_sdgtarget) { FactoryGirl.create(:sdgtarget, draft: true) }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'all published sdgtargets (no drafts)' do
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'guest will not see draft sdgtargets' do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end

      it 'contributor will see draft sdgtargets' do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end

      it 'manager will see draft sdgtargets' do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end
    end
  end

  describe 'Get show' do
    let(:sdgtarget) { FactoryGirl.create(:sdgtarget) }
    let(:draft_sdgtarget) { FactoryGirl.create(:sdgtarget, draft: true) }
    subject { get :show, params: { id: sdgtarget }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the sdgtarget' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(sdgtarget.id)
      end

      it 'will not show draft sdgtarget' do
        get :show, params: { id: draft_sdgtarget }, format: :json
        expect(response).to be_not_found
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a sdgtarget' do
        post :create, format: :json, params: { sdgtarget: { title: 'test', description: 'test', reference: 'ref' } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:recommendation) { FactoryGirl.create(:recommendation) }
      let(:category) { FactoryGirl.create(:category) }

      subject do
        post :create,
             format: :json,
             params: {
               sdgtarget: {
                 title: 'test',
                 description: 'test',
                 reference: 'ref'
               }
             }
        # This is an example creating a new recommendation record in the post
        # post :create,
        #      format: :json,
        #      params: {
        #        sdgtarget: {
        #          title: 'test',
        #          description: 'test',
        #          target_date: 'today',
        #          recommendation_sdgtargets_attributes: [ { recommendation_attributes: { title: 'test 1', number: 1 } } ]
        #        }
        #      }
      end

      it 'will not allow a guest to create a sdgtarget' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to create a sdgtarget' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a sdgtarget' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will record what manager created the sdgtarget', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last_modified_user_id'].to_i).to eq user.id
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { sdgtarget: { description: 'desc only' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT update' do
    let(:sdgtarget) { FactoryGirl.create(:sdgtarget) }
    subject do
      put :update,
          format: :json,
          params: { id: sdgtarget,
                    sdgtarget: { title: 'test update', description: 'test update', target_date: 'today update' } }
    end

    context 'when not signed in' do
      it 'not allow updating a sdgtarget' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'will not allow a guest to update a sdgtarget' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to update a sdgtarget' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to update a sdgtarget' do
        sign_in user
        expect(subject).to be_ok
      end

      it 'will reject and update where the last_updated_at is older than updated_at in the database' do
        sign_in user
        sdgtarget_get = get :show, params: { id: sdgtarget }, format: :json
        json = JSON.parse(sdgtarget_get.body)
        current_update_at = json['data']['attributes']['updated_at']

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
                        format: :json,
                        params: { id: sdgtarget,
                                  sdgtarget: { title: 'test update', description: 'test updateeee', target_date: 'today update', updated_at: current_update_at } }
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
                        format: :json,
                        params: { id: sdgtarget,
                                  sdgtarget: { title: 'test update', description: 'test updatebbbb', target_date: 'today update', updated_at: current_update_at } }
          expect(subject).to_not be_ok
        end
      end

      it 'will record what manager updated the sdgtarget', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last_modified_user_id'].to_i).to eq user.id
      end

      it 'will return the latest last_modified_user_id', versioning: true do
        expect(PaperTrail).to be_enabled
        sdgtarget.versions.first.update_column(:whodunnit, contributor.id)
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last_modified_user_id'].to_i).to eq(user.id)
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        put :update, format: :json, params: { id: sdgtarget, sdgtarget: { title: '' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Delete destroy' do
    let(:sdgtarget) { FactoryGirl.create(:sdgtarget) }
    subject { delete :destroy, format: :json, params: { id: sdgtarget } }

    context 'when not signed in' do
      it 'not allow deleting a sdgtarget' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'will not allow a guest to delete a sdgtarget' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to delete a sdgtarget' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a sdgtarget' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
