require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'Get index' do
    subject { get :index, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_unauthorized }
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:manager) { FactoryGirl.create(:user, :manager) }
      let(:manager2) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:contributor2) { FactoryGirl.create(:user, :contributor) }
      let(:admin) { FactoryGirl.create(:user, :admin) }
      let(:admin2) { FactoryGirl.create(:user, :admin) }

      it 'shows only themselves for contributors' do
        contributor2
        manager
        admin
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['id']).to eq(contributor.id.to_s)
      end

      it 'shows all contributors and themselves for managers' do
        contributor
        contributor2
        manager2
        admin
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(3)
        expect(json['data'][0]['id']).to eq(manager.id.to_s)
        expect(json['data'][1]['id']).to eq(contributor2.id.to_s)
        expect(json['data'][2]['id']).to eq(contributor.id.to_s)
      end

      it 'shows all users for admin' do
        contributor
        contributor2
        manager
        manager2
        admin2
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json['data'].length).to eq(6)
      end

    end
  end

  describe 'Get show' do
    let(:user_role) { FactoryGirl.create(:user_role) }
    subject { get :show, params: { id: user_role }, format: :json }

    context 'when not signed in' do
      it 'does not show the user_role' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:manager) { FactoryGirl.create(:user, :manager) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:admin) { FactoryGirl.create(:user, :admin) }

      subject { get :show, params: { id: contributor.id }, format: :json }

      it 'shows no user for guest' do
        sign_in guest
        expect(subject).to be_not_found
      end
      it 'shows user for contributor' do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(contributor.id)
      end
      it 'shows user for manager' do
        sign_in manager
        subject_manager = get :show, params: { id: manager.id }, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json['data']['id'].to_i).to eq(manager.id)
      end
      it 'shows user for admin' do
        sign_in admin
        subject_manager = get :show, params: { id: admin.id }, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json['data']['id'].to_i).to eq(admin.id)
      end
    end
  end

  describe 'Put update' do
    let(:contributor) { FactoryGirl.create(:user, :contributor) }
    let(:admin) { FactoryGirl.create(:user, :admin) }
    subject do
      put :update,
          format: :json,
          params: { id: contributor.id, user: { email: 'test@co.nz', password: 'testtest', name: 'Sam' } }
    end

    context 'when not signed in' do
      it 'not allow updating a user' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      let(:guest) { FactoryGirl.create(:user) }
      let(:contributor) { FactoryGirl.create(:user, :contributor) }
      let(:manager) { FactoryGirl.create(:user, :manager) }
      let(:admin) { FactoryGirl.create(:user, :admin) }

      it 'will not allow a user to update another user' do
        sign_in guest
        expect(subject).to be_not_found
      end

      it 'will allow a an admin to update any user' do
        sign_in admin
        expect(subject).to be_ok
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(contributor.id)
        expect(json['data']['attributes']['email']).to eq 'test@co.nz'
        expect(json['data']['attributes']['name']).to eq 'Sam'
      end

      it 'will allow a user to update themselves' do
        sign_in contributor
        expect(subject).to be_ok
        json = JSON.parse(subject.body)
        expect(json['data']['id'].to_i).to eq(contributor.id)
        expect(json['data']['attributes']['email']).to eq 'test@co.nz'
        expect(json['data']['attributes']['name']).to eq 'Sam'
      end
    end
  end


  describe 'Delete destroy' do
    let(:guest) { FactoryGirl.create(:user) }
    let(:manager_role) { FactoryGirl.create(:role, :manager) }
    let(:manager) { FactoryGirl.create(:user, roles: [manager_role]) }
    let(:contributor_role) { FactoryGirl.create(:role, :contributor) }
    let(:contributor_role2) { FactoryGirl.create(:role, :contributor) }
    let(:contributor) { FactoryGirl.create(:user, roles: [contributor_role]) }
    let(:contributor2) { FactoryGirl.create(:user, roles: [contributor_role2]) }
    let(:admin_role) { FactoryGirl.create(:role, :admin) }
    let(:admin) { FactoryGirl.create(:user, roles: [admin_role]) }

    subject { delete :destroy, format: :json, params: { id: guest } }

    context 'when not signed in' do
      it 'not allow deleting a user_role' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      it 'will not allow a user to delete another user' do
        sign_in guest
        subject = delete :destroy, format: :json, params: { id: manager.id }
        expect(subject).to be_not_found
      end

      it 'will allow a user to delete themselves' do
        sign_in contributor
        subject = delete :destroy, format: :json, params: { id: contributor.id }
        expect(subject).to be_no_content
      end

      it 'will allow an admin to delete another user' do
        sign_in admin
        subject = delete :destroy, format: :json, params: { id: manager.id }
        expect(subject).to be_no_content
      end
    end
  end
end
