#!/usr/bin/ruby

port = ARGV.first

if !port
  print('No port supplied.')
  exit(0)
end

`lsof -t -i tcp:#{ARGV.first} | xargs kill`
