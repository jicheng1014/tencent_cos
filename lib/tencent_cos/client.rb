require_relative './config'
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
      puts "11111111111111111" * 10
      puts uri
      puts request_method
      puts params
      puts "headers= #{headers}"
      url = standard_url(uri, options)
      puts url
      auth_str = auth_helper.sign(url: url, method_name: request_method, params: params, headers: headers)

      headers.merge!(:Authorization => auth_str ) if options[:auth]

      request request_method, url, params, headers
    end

    def auth(uri, request_method, params, headers, options = {})
      url = standard_url(uri)
      auth_helper.sign(url: url, method_name: request_method, params: params, headers: headers)
    end
    
    private 

    def standard_url(uri,options = {})
      puts "222222222222222" * 10
      puts uri
      puts options
      return uri if uri.start_with?("http")
      uri = "/#{uri}" unless uri.start_with?("/")
      "#{config.host(options[:bucket_name], options[:region])}#{uri}"
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

    def request(method,url, params, headers, options = {})
      url = "http://#{url}" unless url.start_with? "http"
      if %w(get delete head).include? method
        if url.include?("?")
          puts "3333333333333333333" * 10
          url = "#{url}&#{params.to_query}"
        else
          puts "44444444444444444" * 10
          url = "#{url}?#{params.to_query}"
        end
        params = {}
      end
      
      do_retry do 
        response = RestClient::Request.execute({
          :method       => method,
          :url          => URI.encode(url),
          :headers      => headers,
          :payload      => params,
          :timeout      => config.timeout}.merge(options[:request_config] || {})
        )
        Nokogiri::XML(response.body) do |config|
          config.strict.noblanks
        end
      end
    end
  end
end