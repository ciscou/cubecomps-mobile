$redis = Redis.new url: (ENV["REDISTOGO_URL"] || "redis://localhost:6379"), db: (Rails.env.test? ? 1 : 0)
