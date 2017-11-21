# frozen_string_literal: true

require_relative './config'
require_relative './helpers/all'
require_relative './auth/authorization'
require_relative './v5/service'
require_relative './v5/object'
require 'rest-client'
require 'nokogiri'

module TencentCos
  class Client
    include V5::Service
    include V5::Object
    attr_accessor :config, :auth_helper

    def initialize(options = nil)
      self.config = Config.new(options)
      self.auth_helper = V5::Authorization.new(config)
      yield(self) if block_given?
    end

    def do_request(uri, request_method, params, headers = {}, options = {})
      url = standard_url(uri, options)
      auth_str = auth_helper.sign(url: url, method_name: request_method, params: params, headers: headers)

      headers[:Authorization] = auth_str if options[:auth]
      params = options[:body] if options[:body]

      request request_method, url, params, headers
    end

    def auth(uri, request_method, params, headers, _options = {})
      url = standard_url(uri)
      auth_helper.sign(url: url, method_name: request_method, params: params, headers: headers)
    end

    private

    def standard_url(uri, options = {})
      UrlHelper.standard_url(config, uri, options)
    end

    def do_retry
      exception = nil
      config.request_retry.times do
        begin
          return yield
        rescue StandardError => e
          puts "shit happens, e = #{e.message}.. "
          exception = e
        end
        raise exception
      end
    end

    def request(method, url, params, headers, options = {})
      url = "http://#{url}" unless url.start_with? "http"
      if %w[get delete].include? method
        url = if url.include?("?")
                "#{url}&#{params.to_query}"
              else
                "#{url}?#{params.to_query}"
              end
        params = {}
      end

      do_retry do
        response = RestClient::Request.execute({
                                                   method: method,
                                                   url: URI.encode(url),
                                                   headers: headers,
                                                   payload: params,
                                                   timeout: config.timeout
                                               }.merge(options[:request_config] || {}))
      end
    end
  end
end
