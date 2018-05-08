require 'rails_helper'
require 'json'

RSpec.describe DueDatesController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }
    let!(:due_date) { FactoryGirl.create(:due_date) }
    let!(:draft_due_date) { FactoryGirl.create(:due_date, draft: true) }

    context 'when not signed in' do
      it 'no due dates are shown' do
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(0)
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'guest will not see any due_dates' do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(0)
      end

      it 'contributor will see all due_dates' do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end

      it 'manager will see all due_dates' do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(2)
      end
    end
  end

  describe 'Get show' do
    let(:due_date) { FactoryGirl.create(:due_date) }
    let(:draft_due_date) { FactoryGirl.create(:due_date, draft: true) }
    subject { get :show, params: { id: due_date }, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_not_found }

      it 'will not show draft due_date' do
        get :show, params: { id: draft_due_date }, format: :json
        expect(response).to be_not_found
      end
    end
  end

  describe 'Post create' do
    context 'when not signed in' do
      it 'not allow creating a due_date' do
        post :create, format: :json, params: { due_date: { due_date: Time.zone.today.to_s } }
        expect(response).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:indicator) { FactoryGirl.create(:indicator) }
      let(:contributor_indicator) { FactoryGirl.create(:indicator, manager: contributor) }

      subject(:with_contributor) do
        post :create,
             format: :json,
             params: {
               due_date: {
                 due_date: Time.zone.today.to_s,
                 indicator_id: contributor_indicator.id
               }
             }
      end

      subject(:without_contributor) do
        post :create,
             format: :json,
             params: {
               due_date: {
                 due_date: Time.zone.today.to_s,
                 indicator_id: indicator.id
               }
             }
      end

      it 'will not allow a guest to create a due_date' do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to create a due_date for a indicator they are not a manager for' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will not allow a contributor to create a due_date for a indicator they are a manager for' do
        sign_in contributor
        expect(with_contributor).to be_forbidden
      end

      it 'will not allow a manager to create a due_date' do
        sign_in user
        expect(subject).to be_forbidden
      end
    end
  end

  describe 'PUT update' do
    let(:due_date) { FactoryGirl.create(:due_date) }
    subject do
      put :update,
          format: :json,
          params: { id: due_date,
                    due_date: { due_date: 1.year.ago.to_s } }
    end

    context 'when not signed in' do
      it 'not allow updating a due_date' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:user) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }

      it 'will not allow a guest to update a due_date' do
        sign_in guest
        expect(subject).to be_not_found
      end

      it 'will not allow a contributor to update a due_date' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will not allow a manager to update a due_date' do
        sign_in user
        expect(subject).to be_forbidden
      end
    end
  end

  describe 'Delete destroy' do
    let(:due_date) { FactoryGirl.create(:due_date) }
    subject { delete :destroy, format: :json, params: { id: due_date } }

    context 'when not signed in' do
      it 'not allow deleting a due_date' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:user) { FactoryGirl.create(:user, :manager) }

      it 'will not allow a guest to delete a due_date' do
        sign_in guest
        expect(subject).to be_not_found
      end

      it 'will not allow a contributor to delete a due_date' do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it 'will not allow a manager to delete a due_date' do
        sign_in user
        expect(subject).to be_forbidden
      end
    end
  end
end
