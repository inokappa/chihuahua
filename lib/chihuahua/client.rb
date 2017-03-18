# coding: utf-8
module Chihuahua
  class Client
    def initialize
      raise 'API Key does not exist.' unless ENV['DATADOG_API_KEY']
      raise 'Application Key does not exist.' unless ENV['DATADOG_APP_KEY']
      @api_key = ENV['DATADOG_API_KEY']
      @app_key = ENV['DATADOG_APP_KEY']
    end

    def dog
      Dogapi::Client.new(@api_key, @app_key)
    end

  end
end
