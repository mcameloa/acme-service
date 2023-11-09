# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new user' do
        expect do
          post :create, params: {
            user: attributes_for(:user)
          }
        end.to change(User, :count).by(1)
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new user' do
        expect do
          post :create, params: {
            user: attributes_for(:user, email: nil)
          }
        end.not_to change(User, :count)
      end
    end
  end
end
