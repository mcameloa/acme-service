# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController do
  let(:user) { create(:user) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'logs in the user' do
        post :create, params: { user: { email: user.email, password: user.password } }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid credentials' do
      it 'does not log in the user' do
        post :create, params: { user: { email: user.email, password: 'wrong_password' } }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when logged in' do
      it 'logs out the user' do
        allow(controller).to receive_messages(current_user: user, jwt_key: 'secure_123')

        sign_in user
        delete :destroy

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when not logged in' do
      it 'does not log out the user' do
        delete :destroy

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'FakeRackSession' do
    controller(ApplicationController) do
      include RackSessionsFix
    end

    it 'responds to enabled?' do
      session = RackSessionsFix::FakeRackSession.new
      expect(session.enabled?).to be(false)
    end
  end
end
