require "sinatra"
require "redis"
require "hiredis"

redis = Redis.new(:driver => :hiredis)

get "/" do
  redis.hgetall("counters").to_s + "\n"
end

get "/hit" do
  redis.pipelined do
    redis.hincrby("counters", "total", "1")
    redis.hincrby("counters", "count-#{ENV['SERVER_NUMBER']}", "1")
  end
  "OK\n"
end

get "/heartbeat" do
  "OK\n"
end
