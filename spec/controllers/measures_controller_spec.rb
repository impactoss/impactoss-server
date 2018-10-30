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
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'guest will not see draft measures' do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
      end

      it 'contributor will see draft measures' do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end

      it 'manager will see draft measures' do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end
    end

    context 'filters' do
      let(:category) { FactoryGirl.create(:category) }
      let(:measure_different_category) { FactoryGirl.create(:measure) }
      let(:recommendation) { FactoryGirl.create(:recommendation) }
      let(:measure_different_recommendation) { FactoryGirl.create(:measure) }
      let(:indicator) { FactoryGirl.create(:indicator) }
      let(:measure_different_indicator) { FactoryGirl.create(:measure) }

      it 'filters from category' do
        measure_different_category.categories << category
        subject = get :index, params: { category_id: category.id }, format: :json
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['id']).to eq(measure_different_category.id.to_s)
      end

      it 'filters from recommendation' do
        measure_different_recommendation.recommendations << recommendation
        subject = get :index, params: { recommendation_id: recommendation.id }, format: :json
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['id']).to eq(measure_different_recommendation.id.to_s)
      end

      it 'filters from indicator' do
        measure_different_indicator.indicators << indicator
        subject = get :index, params: { indicator_id: indicator.id }, format: :json
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['id']).to eq(measure_different_indicator.id.to_s)
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
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:recommendation) { FactoryGirl.create(:recommendation) }
      let(:category) { FactoryGirl.create(:category) }

      subject do
        post :create,
             format: :json,
             params: {
               measure: {
                 title: 'test',
                 description: 'test',
                 target_date: 'today'
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

      it 'will not allow a guest to create a measure' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to create a measure' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to create a measure' do
        sign_in user
        expect(subject).to be_created
      end

      it 'will record what manager created the measure', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last_modified_user_id'].to_i).to eq user.id
      end

      it 'will return an error if params are incorrect' do
        sign_in user
        post :create, format: :json, params: { measure: { description: 'desc only' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT update' do
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
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'will not allow a guest to update a measure' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to update a measure' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to update a measure' do
        sign_in user
        expect(subject).to be_ok
      end

      it 'will reject and update where the last_updated_at is older than updated_at in the database' do
        sign_in user
        measure_get = get :show, params: { id: measure }, format: :json
        json = JSON.parse(measure_get.body)
        current_update_at = json['data']['attributes']['updated_at']

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
                        format: :json,
                        params: { id: measure,
                                  measure: { title: 'test update', description: 'test updateeee', target_date: 'today update', updated_at: current_update_at } }
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
                        format: :json,
                        params: { id: measure,
                                  measure: { title: 'test update', description: 'test updatebbbb', target_date: 'today update', updated_at: current_update_at } }
          expect(subject).to_not be_ok
        end
      end

      it 'will record what manager updated the measure', versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last_modified_user_id'].to_i).to eq user.id
      end

      it 'will return the latest last_modified_user_id', versioning: true do
        expect(PaperTrail).to be_enabled
        measure.versions.first.update_column(:whodunnit, contributor.id)
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data']['attributes']['last_modified_user_id'].to_i).to eq(user.id)
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
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'will not allow a guest to delete a measure' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to delete a measure' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will allow a manager to delete a measure' do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
