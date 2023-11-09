# frozen_string_literal: true

# User controller
class UsersController < ApplicationController
  def show
    render json: UserSerializer.new(current_user)
  end
end
