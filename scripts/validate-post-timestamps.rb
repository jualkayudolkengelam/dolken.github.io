# frozen_string_literal: true

require "optparse"
require_relative "lib/post_timestamps"

root = Dir.pwd
OptionParser.new do |parser|
  parser.banner = "Usage: validate-post-timestamps.rb [--root PATH]"
  parser.on("--root PATH") { |value| root = value }
end.parse!

result = PostTimestamps.validate(root: root)
if result.success?
  puts "OK: #{PostTimestamps.articles(root).size} artikel, timestamp UTC unik"
else
  result.errors.each { |error| warn "ERROR: #{error}" }
  exit 1
end
