#!/usr/bin/env ruby

require 'json'
require 'open-uri'

def get_json(path)
  print "getting #{path}..."
  sleep 0.1
  json = JSON.parse open("http://m.cubecomps.com#{path}.json").read
                    open("http://m.cubecomps.com#{path}"     ).read
  puts " Done"
  json
end

def warm_cache_for(competitions)
  competitions.each do |competition|
    events = get_json("/competitions/#{competition["id"]}/events")
    events.each do |event|
      event["rounds"].each do |round|
        get_json("/competitions/#{round["competition_id"]}/events/#{round["event_id"]}/rounds/#{round["id"]}/results") if round["id"]
      end
    end
  end
end

start = Time.now

competitions = get_json("/competitions")
warm_cache_for competitions["in_progress"]

# competitions = get_json("/competitions/past")
# warm_cache_for competitions["past"]

puts "Finished in #{Time.now - start} seconds"
