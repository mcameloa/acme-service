# spec/integration/sessions_specs.rb
require 'swagger_helper'

describe 'Sessions API' do
  path '/login' do
    post 'Login user' do
      tags 'Session'
      consumes 'application/json', 'application/xml'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
            }
          }
        },
        required: %w[email password time_zone]
      }

      response '200', 'login' do
        User.create(email: 'user@example.com', password: 'password')
        let(:user) { { user: { email: 'user@example.com', password: 'password' } } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:user) { { user: { email: 'example@mail.com' } } }
        run_test!
      end
    end
  end
end
