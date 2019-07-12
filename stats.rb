# Usage:
# $ heroku logs --app cubecomps-mobile --num 0 --source heroku --tail | ruby stats.rb

INFO_RE = %r{
  \A
  (\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}\+\d{2}:\d{2})
  \s
  heroku\[router\]:
  \s
  at=info
  \s
  method=([A-Z]+)
  \s
  path="(?<path>[^"]+)"
  \s
  host=m\.cubecomps\.com
  \s
  request_id=[a-f0-9-]+
  \s
  fwd="(?<fwd>[^"]+)"
  \s
  dyno=web.1
  \s
  connect=[0-9]+ms
  \s
  service=[0-9]+ms
  \s
  status=([0-9]+)
  \s
  bytes=[0-9]*
  \s
  protocol=https?
  \z
}x

WARNING_RE = %r{
  \A
  (\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}\+\d{2}:\d{2})
  \s
  heroku\[router\]:
  \s
  sock=client
  \s
  at=warning
  \s
  code=(H\d+)
  \s
  desc="([^"]+)"
  \s
  method=([A-Z]+)
  \s
  path="(?<path>[^"]+)"
  \s
  host=m\.cubecomps\.com
  \s
  request_id=[a-f0-9-]+
  \s
  fwd="(?<fwd>[^"]+)"
  \s
  dyno=web.1
  \s
  connect=[0-9]+ms
  \s
  service=[0-9]+ms
  \s
  status=([0-9]+)
  \s
  bytes=[0-9]*
  \s
  protocol=https?
  \z
}x

ERROR_RE = %r{
  \A
  (\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}\+\d{2}:\d{2})
  \s
  heroku\[router\]:
  \s
  sock=client
  \s
  at=error
  \s
  code=(H\d+)
  \s
  desc="([^"]+)"
  \s
  method=([A-Z]+)
  \s
  path="(?<path>[^"]+)"
  \s
  host=m\.cubecomps\.com
  \s
  request_id=[a-f0-9-]+
  \s
  fwd="(?<fwd>[^"]+)"
  \s
  dyno=web.1
  \s
  connect=[0-9]+ms
  \s
  service=[0-9]+ms
  \s
  status=([0-9]+)
  \s
  bytes=[0-9]*
  \s
  protocol=https?
  \z
}x

info    = 0
warning = 0
error   = 0
unknown = 0

apiv2 = 0
apiv1 = 0
apiv0 = 0
web   = 0

requests_by_fwd = Hash.new(0)

requests_by_path = Hash.new(0)

requests_by_competition_id = Hash.new(0)

active_users = {}

begin
  while s = gets
    s.chomp!

    case s
    when INFO_RE, WARNING_RE, ERROR_RE
      path = $~[:path]

      if path.start_with?("/api/v2")
        apiv2 += 1
      elsif path.start_with?("/api/v1")
        apiv1 += 1
      elsif path.end_with?(".json")
        apiv0 += 1
      else
        web += 1
      end

      requests_by_path[path] += 1

      fwd = $~[:fwd]

      requests_by_fwd[fwd] += 1

      active_users[fwd] = Time.now.to_i

      if path =~ %r{/competitions/(\d+)}
        competition_id = $~[1]

        requests_by_competition_id[competition_id] += 1
      end
    end

    case s
    when INFO_RE
      info += 1
    when WARNING_RE
      warning += 1
    when ERROR_RE
      error += 1
    else
      unknown += 1
      puts "Unknown line format:"
      puts s
    end

    active_users.delete_if do |k, v|
      Time.now.to_i - v > 120
    end
    puts "Active users: #{active_users.count}"
  end
rescue Interrupt
  puts
  puts
end

puts "Info:    #{info}"
puts "Warning: #{warning}"
puts "Error:   #{error}"
puts "Unknown: #{unknown}"

puts

puts "Api v2: #{apiv2}"
puts "Api v1: #{apiv1}"
puts "Api v0: #{apiv0}"
puts "Web:    #{web}"

puts

puts "Most requests by IP"
requests_by_fwd.sort_by { |_k, v| v }.reverse.first(10).each do |k, v|
  puts "#{v}: #{k}"
end

puts

puts "Most requests by path"
requests_by_path.sort_by { |_k, v| v }.reverse.first(10).each do |k, v|
  puts "#{v}: #{k}"
end

puts

puts "Most requests by competition"
requests_by_competition_id.sort_by { |_k, v| v }.reverse.first(10).each do |k, v|
  puts "#{v}: #{k}"
end
