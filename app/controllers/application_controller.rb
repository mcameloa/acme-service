# frozen_string_literal: true

# Base controller for Acme API Project.
class ApplicationController < ActionController::API
  before_action :authorize, :set_timezone, :user_quota
  before_action :configure_permitted_parameters, if: :devise_controller?

  def set_timezone
    Time.zone = current_user&.time_zone if current_user
  end

  def user_quota
    if user_hit_counter.value >= ENV['MAX_HITS'].to_i
      render json: { error: 'over quota' }, status: :too_many_requests
    else
      save_hit
    end
  end

  def save_hit
    user_hit_counter.increment
    Hit.create(
      user_id: session[:user_id],
      endpoint: request.original_url
    )
  end

  private

  def user_hit_counter
    @counter = Redis::Counter.new("#{Time.zone.now.strftime('%Y-%m')}-#{current_user.id}")
  end

  def authorize
    render_unauthorized if jwt_key.blank? || !current_user
  end

  def render_unauthorized
    render json: 'Unauthorized', status: :unauthorized
  end

  def jwt_key
    if request.headers['Authorization'].present?
      jwt_payload = JWT.decode(request.headers['Authorization'].split.last,
                               Rails.application.credentials.devise_jwt_secret_key!).first
      jwt_payload['sub']
    end
  rescue JWT::DecodeError
    nil
  end

  def current_user
    @current_user ||= User.where(id: jwt_key).first
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[time_zone])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[time_zone])
  end
end
