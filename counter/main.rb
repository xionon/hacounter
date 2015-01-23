require "sinatra"
require "redis"
require "hiredis"
require "yaml"

redis_config = YAML.load_file('redis.yml')
redis = Redis.new(:host => redis_config["hosts"][0], :driver => :hiredis)
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
