# frozen_string_literal: true

# User Serializer
class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :time_zone
end
