# frozen_string_literal: true

# spec/controllers/application_controller_spec.rb
require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    def index
      render json: {}, status: :ok
    end
  end

  let(:user) { create(:user) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    allow(controller).to receive_messages(current_user: user, jwt_key: 'secure_123')

    allow(controller).to receive(:authorize).and_call_original
    allow(controller).to receive(:set_timezone).and_call_original
    allow(controller).to receive(:user_quota).and_call_original
    allow(controller).to receive(:save_hit).and_call_original
    allow(controller).to receive(:configure_permitted_parameters)
  end

  describe 'before actions' do
    it 'calls :authorize before actions' do
      get :index
      expect(controller).to have_received(:authorize)
    end

    it 'calls :set_timezone before actions' do
      get :index
      expect(controller).to have_received(:set_timezone)
    end

    it 'calls :user_quota before actions' do
      get :index
      expect(controller).to have_received(:user_quota)
    end

    it 'calls :configure_permitted_parameters before actions if devise_controller' do
      allow(controller).to receive(:devise_controller?).and_return(true)
      get :index
      expect(controller).to have_received(:configure_permitted_parameters)
    end
  end

  describe '#set_timezone' do
    it 'sets the timezone from the current_user' do
      user_time_zone = 'Eastern Time (US & Canada)'
      user.update(time_zone: user_time_zone)
      get :index
      expect(Time.zone.name).to eq user_time_zone
    end
  end

  describe '#user_quota' do
    before do
      Redis::Counter.new("2023-11-#{user.id}").value = ENV['MAX_HITS'].to_i
      user.update(time_zone: 'Australia/Sydney') # Prefer `update` over `save` for one-liner.
    end

    it 'renders over quota when hits are over the limit' do
      allow(controller).to receive(:user_hit_counter).and_return(
        instance_double(Redis::Counter, value: ENV['MAX_HITS'].to_i + 1)
      )

      get :index
      expect(response).to have_http_status(:too_many_requests)
    end

    it 'saves the hit when under the limit' do
      allow(controller).to receive(:user_hit_counter).and_return(
        instance_double(Redis::Counter, value: ENV['MAX_HITS'].to_i - 1, increment: true)
      )

      get :index
      expect(controller).to have_received(:save_hit)
    end

    it 'restarts quota at beginning of the month' do
      Redis::Counter.new("2023-11-#{user.id}").value = ENV['MAX_HITS'].to_i
      t = Time.zone.local(2023, 12, 15, 0, 0, 0)
      Timecop.travel(t)

      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'restarts quota at the beginning of the month on different time zones' do
      travel_to_month_end('America/Bogota')
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#authorize' do
    it 'has jwt_key' do
      allow(controller).to receive_messages(current_user: user, jwt_key: 'secure_123')
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'has not jwt_key' do
      allow(controller).to receive_messages(current_user: user, jwt_key: '')
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '#jwt_key and #current_user' do
    let(:valid_token) { 'valid_token' }
    let(:invalid_token) { 'invalid_token' }

    before do
      allow(JWT).to receive(:decode)
        .with(valid_token, Rails.application.credentials.devise_jwt_secret_key!)
        .and_return([{ 'sub' => user.id }])

      allow(JWT).to receive(:decode)
        .with(invalid_token, Rails.application.credentials.devise_jwt_secret_key!)
        .and_raise(JWT::DecodeError)
      allow(controller).to receive(:jwt_key).and_call_original
      allow(controller).to receive(:current_user).and_call_original
    end

    it 'authorizes with valid token' do
      request.headers['Authorization'] = "Bearer #{valid_token}"
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'does not authorize with invalid token' do
      request.headers['Authorization'] = "Bearer #{invalid_token}"
      get :index
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not authorize without user' do
      request.headers['Authorization'] = "Bearer #{valid_token}"
      user.delete
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'Devise parameters' do
    controller(described_class) do
      include Devise::Controllers::Helpers
      def index
        render json: {}, status: :ok
      end

      def resource_class
        User
      end

      def resource_name
        'User'
      end
    end

    it 'calls configure_permitted_parameters if devise_controller' do
      allow(controller).to receive(:devise_controller?).and_return(true)
      allow(controller).to receive(:configure_permitted_parameters).and_call_original
      get :index
      expect(controller).to have_received(:configure_permitted_parameters)
    end
  end
end
