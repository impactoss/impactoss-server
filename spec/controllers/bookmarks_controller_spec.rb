require 'rails_helper'

RSpec.describe BookmarksController, type: :controller do
  describe 'Get index' do
    let(:bookmark1) { FactoryGirl.create(:bookmark) }
    let(:bookmark2) { FactoryGirl.create(:bookmark) }
    let(:user) { FactoryGirl.create(:user, bookmarks: [bookmark1]) }

    subject { get :index, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_unauthorized }
    end

    context 'when signed in' do
      it 'lists bookmars for signed in user' do
        sign_in user

        expect(subject).to have_http_status(200)

        response = JSON.parse(subject.body)
        expect(response['data'].length).to eq(1)

        bookmark = response['data'][0]['attributes']
        expect(bookmark['user_id']).to eq(user.id)
      end
    end
  end

  describe 'Get show' do
    let(:bookmark) { FactoryGirl.create(:bookmark) }
    let(:user) { FactoryGirl.create(:user, bookmarks: [bookmark]) }

    subject { get :show, params: {id: bookmark['id']}, format: :json }

    context 'when not signed in' do
      it { expect(subject).to be_unauthorized }
    end

    context 'when signed in' do

      it 'is forbidden' do
        sign_in user

        expect(subject).to have_http_status(403)
      end
    end
  end

  describe 'Post create' do
    let(:user) { FactoryGirl.create(:user) }

    invalid_params = {
      bookmark: {bookmark_type: 1, title: 'test 2'}
    }

    subject { post :create, format: :json, params: {
      bookmark: {bookmark_type: 1, title: 'test 1', view: {lorem: 'ipsum'}}
    }}

    context 'when not signed in' do
      it 'not allow creating a bookmark' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when signed in' do
      it 'not allow creating a bookmark if view is missing' do
        sign_in user

        subject = post :create, format: :json, params: invalid_params
        response = JSON.parse(subject.body)

        expect(subject).to have_http_status(422)
        expect(response['view'][0]).to eq('can\'t be blank')
      end

      it 'allow creating a bookmark' do
        sign_in user

        expect(subject).to have_http_status(201)
      end
    end
  end

  describe 'Put update' do
    let(:bookmark1) { FactoryGirl.create(:bookmark) }
    let(:bookmark2) { FactoryGirl.create(:bookmark) }
    let(:user) { FactoryGirl.create(:user, bookmarks: [bookmark1]) }

    new_title = 'new title'
    new_view = {dolor: 'sit amet'}

    subject { put :update, format: :json, params: {
      id: bookmark1.id, bookmark: {title: new_title, view: new_view}
    }}

    context 'when not signed in' do
      it 'not allow updating a bookmark' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      it 'allow updating a bookmark that belongs to the user' do
        sign_in user

        expect(subject).to have_http_status(200)

        updated = Bookmark.find(bookmark1.id)
        expect(updated.title).to eq(new_title)
        expect(updated.view.to_json).to eq(new_view.to_json)
      end

      it 'not allow updating a bookmark that does not belong to the user' do
        sign_in user

        subject = put :update, format: :json, params: {
          id: bookmark2.id, bookmark: {title: new_title, view: new_view}
        }

        expect(subject).to have_http_status(403)
      end
    end
  end

  describe 'Delete destroy' do
    let(:bookmark1) { FactoryGirl.create(:bookmark) }
    let(:bookmark2) { FactoryGirl.create(:bookmark) }
    let(:user) { FactoryGirl.create(:user, bookmarks: [bookmark1]) }

    subject { delete :destroy, format: :json, params: { id: bookmark1.id } }

    context 'when not signed in' do
      it 'not allow deleting a bookmark' do
        expect(subject).to be_unauthorized
      end
    end

    context 'when user signed in' do
      it 'allow deleteing a bookmark that belongs to the user' do
        sign_in user

        expect(subject).to have_http_status(204)
      end

      it 'not allow deleting a bookmark that does not belong to the user' do
        sign_in user

        subject = delete :destroy, format: :json, params: { id: bookmark2.id }

        expect(subject).to have_http_status(403)
      end
    end
  end
end
