$redis = Redis.new url: (ENV["REDISTOGO_URL"] || "redis://localhost:6379")
