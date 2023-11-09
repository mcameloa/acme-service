# frozen_string_literal: true

# Session controller
class SessionsController < Devise::SessionsController
  include RackSessionsFix

  skip_before_action :authorize, :user_quota, :set_timezone

  respond_to :json

  def respond_with(current_user, _opts = {})
    render json: {
      status: {
        code: 200, message: 'Logged in successfully.',
        data: { user: UserSerializer.new(current_user).serializable_hash[:data][:attributes] }
      }
    }, status: :ok
  end

  def respond_to_on_destroy
    if current_user
      render json: { status: 200, message: 'Logged out successfully.' }, status: :ok
    else
      render_unauthorized
    end
  end
end
