# frozen_string_literal: true

# Rack session fix Module
module RackSessionsFix
  extend ActiveSupport::Concern

  # Workaround for Rails 7.0 devise session management.
  class FakeRackSession < Hash
    def enabled?
      false
    end

    def destroy; end
  end
  included do
    before_action :set_fake_session

    private

    def set_fake_session
      request.env['rack.session'] ||= FakeRackSession.new
    end
  end
end
