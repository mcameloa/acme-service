require 'swagger_helper'

describe 'Users API' do

  path '/users/{id}' do

    get 'Retrieves a user' do
      tags 'Users'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string
      parameter name: 'Authorization', in: :header, type: :string, required: true

      let(:user) { create(:user) }
      let(:id) { user.id }
      let(:Authorization) { "Bearer secure_123" }
      let(:valid_token) { 'secure_123' }

      before do
        allow(JWT).to receive(:decode)
                        .with(valid_token, Rails.application.credentials.devise_jwt_secret_key!)
                        .and_return([{ 'sub' => id }])
      end

      response '200', 'user found' do
        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { "A" }
        run_test!
      end
    end
  end
end
