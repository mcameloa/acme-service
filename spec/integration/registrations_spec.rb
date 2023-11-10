# spec/integration/registrations_specs.rb
require 'swagger_helper'

describe 'Registration API' do
  path '/signup' do
    post 'Create user' do
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
              time_zone: { type: :string },
            }
          }
        },
        required: %w[email password time_zone]
      }

      response '200', 'user created' do
        let(:user) { { user: { email: 'test@example.com', password: '12345678', time_zone: 'Europe/Copenhagen' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:user) { { user: { email: 'example@mail.com' } } }
        run_test!
      end
    end
  end
end
