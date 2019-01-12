module Atomsphere
  VERSION = '0.1.6'
  ROOT = "#{File.expand_path(__dir__)}/atomsphere"

  %w(configuration query api action).each{ |m| require "#{ROOT}/#{m}" }
end
