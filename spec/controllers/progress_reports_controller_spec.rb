# frozen_string_literal: true
require 'rails_helper'
require 'json'

RSpec.describe ProgressReportsController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }
    let!(:progress_report) { FactoryGirl.create(:progress_report) }
    let!(:draft_progress_report) { FactoryGirl.create(:progress_report, draft: true) }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'all published progress_reports (no drafts)' do
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'guest will not see draft progress_reports' do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end

      it 'manager will see draft progress_reports' do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end
    end
  end

  describe 'Get show' do
    let(:progress_report) { FactoryGirl.create(:progress_report) }
    let(:draft_progress_report) { FactoryGirl.create(:progress_report, draft: true) }
    subject { get :show, params: { id: progress_report }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_ok }

      it 'shows the progress_report' do
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(progress_report.id)
      end

      it 'will not show draft progress_report' do
        get :show, params: { id: draft_progress_report }, format: :json
        expect(response).to be_not_found
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a progress_report' do
        post :create, format: :json, params: { progress_report: { title: 'test',
                                                                  description: 'test',
                                                                  target_date: 'today' } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:due_date) { FactoryGirl.create(:due_date) }
      let(:indicator) { FactoryGirl.create(:indicator) }

      subject do
        post :create,
             format: :json,
             params: {
               progress_report: {
                 indicator_id: indicator.id,
                 due_date_id: due_date.id,
                 title: 'test title',
                 description: 'test desc',
                 document_url: 'test_url',
                 document_public: true
               }
             }
        # This is an example creating a new recommendation record in the post
        # post :create,
        #      format: :json,
        #      params: {
        #        measure: {
        #          title: 'test',
        #          description: 'test',
        #          target_date: 'today',
        #          recommendation_measures_attributes: [ { recommendation_attributes: { title: 'test 1', number: 1 } } ]
        #        }
        #      }
      end

      it 'will not allow a guest to create a progress_report' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a progress_report' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will record what manager created the progress_report', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last-modified-user-id'].to_i).to eq user.id
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { progress_report: { description: 'desc only' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Put update' do
    let(:progress_report) { FactoryGirl.create(:progress_report) }
    subject do
      put :update,
          format: :json,
          params: { id: progress_report,
                    progress_report: { title: 'test update', description: 'test update' } }
    end

    context 'when not signed in' do
      it 'not allow updating a progress_report' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to update a progress_report' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to update a progress_report' do
        sign_in user
        expect(subject).to be_ok
      end

      it 'will record what manager updated the progress_report', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last-modified-user-id'].to_i).to eq user.id
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        put :update, format: :json, params: { id: progress_report, progress_report: { title: '' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Delete destroy' do
    let(:progress_report) { FactoryGirl.create(:progress_report) }
    subject { delete :destroy, format: :json, params: { id: progress_report } }

    context 'when not signed in' do
      it 'not allow deleting a progress_report' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to delete a progress_report' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a progress_report' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
