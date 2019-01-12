module Atomsphere
  module Api
  end

  %w(response client).each{ |m| require "#{ROOT}/api/#{m}" }
end
