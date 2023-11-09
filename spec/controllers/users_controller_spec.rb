# frozen_string_literal: true

# spec/controllers/users_controller_spec.rb
require 'rails_helper'

RSpec.describe UsersController do
  let(:user) { create(:user) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in user

    allow(controller).to receive_messages(current_user: user, jwt_key: 'secure_123')
  end

  describe 'GET #show' do
    before { get :show, params: { id: user.id } }

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'returns the current_user as JSON' do
      expected_data = UserSerializer.new(user).serializable_hash.to_json
      expect(response.body).to eq expected_data
    end
  end
end
