require "sinatra"
require "redis"
require "hiredis"

redis = Redis.new(:host => "192.168.33.10", :driver => :hiredis)
hostname = `hostname`.strip

get "/" do
  redis.hgetall("counters").to_s + "\n"
end

get "/hit" do
  redis.pipelined do
    redis.hincrby("counters", "total", "1")
    redis.hincrby("counters", "count-#{hostname}", "1")
  end
  "OK\n"
end

get "/heartbeat" do
  "OK\n"
end
