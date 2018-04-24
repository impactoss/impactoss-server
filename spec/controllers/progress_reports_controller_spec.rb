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
      let(:manager) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'guest will not see draft progress_reports' do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end

      it 'contributor will see draft progress_reports' do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end

      it 'manager will see draft progress_reports' do
        sign_in manager
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
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:due_date) { FactoryGirl.create(:due_date) }
      let(:indicator) { FactoryGirl.create(:indicator) }
      let(:contributor_indicator) { FactoryGirl.create(:indicator, manager: contributor) }

      subject(:without_contributor_manager) do
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

      subject(:with_contributor_manager) do
        post :create,
             format: :json,
             params: {
               progress_report: {
                 indicator_id: contributor_indicator.id,
                 due_date_id: due_date.id,
                 title: 'test title',
                 description: 'test desc',
                 document_url: 'test_url',
                 document_public: true
               }
             }
      end

      it 'will allow a guest to create a progress_report' do
        sign_in guest
        expect(subject).to be_created
      end

      # This was changed from forbidden in bb687a69339aaa3501f24140907e9a2135ffe4c5 per #154
      it 'will allow a contributor to create a progress_report when they are not a manager for the indicator' do
        sign_in contributor
        expect(without_contributor_manager).to be_created
      end

      it 'will allow a contributor to create a progress_report when they are the manager for the indicator' do
        sign_in contributor
        expect(with_contributor_manager).to be_created
      end

      it 'will allow a manager to create a progress_report' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will record what manager created the progress_report', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last_modified_user_id'].to_i).to eq user.id
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { progress_report: { description: 'desc only' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT update' do
    let(:progress_report) { FactoryGirl.create(:progress_report) }

    subject(:without_contributor_manager) do
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
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:contributor_indicator) { FactoryGirl.create(:indicator, manager: contributor) }
      let(:progress_report_with_contributor) { FactoryGirl.create(:progress_report, indicator: contributor_indicator) }

      subject(:with_contributor_manager) do
        put :update,
            format: :json,
            params: { id: progress_report_with_contributor,
                      progress_report: { title: 'test update', description: 'test update' } }
      end

      it 'will not allow a guest to update a progress_report' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to update a progress_report when they are not a manager for the indicator' do
        sign_in contributor
        expect(without_contributor_manager).to be_forbidden
      end

      it 'will allow a contributor to update a progress_report when they are the manager for the indicator' do
        sign_in contributor
        expect(with_contributor_manager).to be_ok
      end

      it 'will allow a manager to update a progress_report' do
        sign_in user
        expect(subject).to be_ok
      end

      it 'will reject and update where the last_updated_at is older than updated_at in the database' do
        sign_in user
        progress_report_get = get :show, params: { id: progress_report_with_contributor }, format: :json
        json = JSON.parse(progress_report_get.body)
        current_update_at = json['data']['attributes']['updated_at']

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
                        format: :json,
                        params: { id: progress_report_with_contributor,
                                  progress_report: { title: 'test update', description: 'test updateeee', target_date: 'today update', updated_at: current_update_at } }
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
                        format: :json,
                        params: { id: progress_report_with_contributor,
                                  progress_report: { title: 'test update', description: 'test updatebbbb', target_date: 'today update', updated_at: current_update_at } }
          expect(subject).to_not be_ok
        end
      end

      it 'will record what manager updated the progress_report', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last_modified_user_id'].to_i).to eq user.id
      end

      it 'will return the latest last_modified_user_id', versioning: true do
        expect(PaperTrail).to be_enabled
        progress_report.versions.first.update_column(:whodunnit, contributor.id)
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last_modified_user_id'].to_i).to eq(user.id)
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
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'will not allow a guest to delete a progress_report' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to delete a progress_report' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a progress_report' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
