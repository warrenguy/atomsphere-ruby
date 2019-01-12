module Atomsphere
  class Configuration
    REQUIRED = :username, :password, :account_id
    OPTIONAL = :base_uri, :otp_secret
    VARS = REQUIRED + OPTIONAL

    VARS.each { |v| attr_accessor v }

    def initialize
      @base_uri = 'https://api.boomi.com/api/rest/v1/'
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration

    configuration
  end
end

Hash[Atomsphere::Configuration::VARS.map do |v|
  [v, "BOOMI_#{v.upcase}"]
end].each do |v, e|
  Atomsphere.configure do |config|
    config.send :"#{v}=", ENV[e]
  end if ENV.keys.include? e
end
