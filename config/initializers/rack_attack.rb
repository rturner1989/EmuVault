Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))

# Throttle general requests by IP
Rack::Attack.throttle("req/ip", limit: 300, period: 5.minutes) do |req|
  req.ip
end

# Throttle file upload endpoints more aggressively
Rack::Attack.throttle("uploads/ip", limit: 30, period: 5.minutes) do |req|
  req.ip if req.post? && req.path.include?("/upload")
end

# Block obviously malicious user agents
Rack::Attack.blocklist("block malicious agents") do |req|
  req.user_agent&.match?(/masscan|zgrab|nikto|sqlmap/i)
end
