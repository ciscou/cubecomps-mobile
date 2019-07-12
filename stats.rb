info_log_re = %r{
  \A
  (\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}\+\d{2}:\d{2})
  \s
  heroku\[router\]:
  \s
  at=info
  \s
  method=([A-Z]+)
  \s
  path="([^"]+)"
  \s
  host=m\.cubecomps\.com
  \s
  request_id=[a-f0-9-]+
  \s
  fwd="([^"]+)"
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

error_log_re = %r{
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
  desc=("[^"]+")
  \s
  method=([A-Z]+)
  \s
  path=("[^"]+")
  \s
  host=m\.cubecomps\.com
  \s
  request_id=[a-f0-9-]+
  \s
  fwd="([^"]+)"
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

warning_log_re = %r{
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
  desc=("[^"]+")
  \s
  method=([A-Z]+)
  \s
  path=("[^"]+")
  \s
  host=m\.cubecomps\.com
  \s
  request_id=[a-f0-9-]+
  \s
  fwd="([^"]+)"
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
error   = 0
warning = 0
unknown = 0

begin
  while s = gets
    s.chomp!

    case s
    when info_log_re
      info += 1
    when error_log_re
      error += 1
    when warning_log_re
      warning += 1
    else
      unknown += 1
      puts s
    end
  end
rescue Interrupt
  puts
  puts
end

puts "Info:    #{info}"
puts "Error:   #{error}"
puts "Warning: #{warning}"
puts "Unknown: #{unknown}"
