# frozen_string_literal: true

Redis::Objects.redis = Redis.new(host: '127.0.0.1', port: 6379)
