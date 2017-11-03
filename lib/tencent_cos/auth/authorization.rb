# frozen_string_literal: true

require_relative '../../vendors/all'
require 'base64'
require 'ostruct'
require 'openssl'
require 'uri'

module TencentCos
  module V5
    class Authorization
      attr_accessor :secret_id, :secret_key, :duration_seconds, :force_sign_time

      def initialize(config = nil)
        init(config)
        yield(self) if block_given?
      end

      def init(config)
        return if config.nil?
        config = OpenStruct.new(config) if config.is_a? Hash
        self.secret_id = config.secret_id
        self.secret_key = config.secret_key
        # self.bucket_name = config.bucket_name
        self.duration_seconds = config.duration_seconds || 3600
      end

      def sign(request_info)
        request_info = OpenStruct.new(request_info) if request_info.is_a? Hash

        sign_time = self.sign_time
        url = request_info.url
        puts url
        path = path(url)
        method_name = request_info.method_name.downcase
        sorted_params = param_list(request_info.params)
        sorted_headers = param_list(request_info.headers)

        puts "#{sign_time}, #{method_name}, #{path},#{sorted_headers}, #{sorted_params}"

        signature = signature(sign_time, method_name, path, sorted_headers, sorted_params)

        "q-sign-algorithm=sha1&q-ak=#{secret_id}&q-sign-time=#{sign_time}&q-key-time=#{sign_time}\
&q-header-list=#{cleand_dict(request_info.headers).keys.join(';')}\
&q-url-param-list=#{cleand_dict(request_info.params).keys.join(';')}\
&q-signature=#{signature}"
      end

      def sign_time(begin_time = nil, end_time = nil)
        return force_sign_time unless force_sign_time.nil?
        begin_time ||= Time.now
        end_time ||= begin_time + duration_seconds
        "#{begin_time.to_i};#{end_time.to_i}"
      end

      def signed_header_list(request)
        request.headers.keys.sort.map(&:downcase)
      end

      def signed_param_list(request)
        request.params.keys.sort.map(&:downcase)
      end

      def extract_url(request)
        if request[:url]
          URI.parse(request[:url].to_s)
        else
          msg = "missing required option :url"
          raise ArgumentError, msg
        end
      end

      def signature(sign_time, method, path, headers, params)
        # 原理
        # SignKey = HMAC-SHA1(SecretKey,"[q-key-time]")
        # HttpString = [HttpMethod]\n[HttpURI]\n[HttpParameters]\n[HttpHeaders]\n
        # StringToSign = [q-sign-algorithm]\n[q-sign-time]\nSHA1-HASH(HttpString)\n
        # Signature = HMAC-SHA1(SignKey,StringToSign)

        q_sign_algorithm = "sha1"
        hmac_sha1 = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret_key, sign_time)
        puts "hmac_sha1 = #{hmac_sha1}"

        http_string = "#{method}\n#{path}\n#{params.join('&')}\n#{headers.join('&')}\n"
        puts "http_string = #{http_string}"

        sha1_http_string = Digest::SHA1.hexdigest(http_string)
        puts "sha1_http_string = #{sha1_http_string}"

        sign_string = "#{q_sign_algorithm}\n#{sign_time}\n#{sha1_http_string}\n"

        puts "sign_string = #{sign_string}"

        signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), hmac_sha1, sign_string)
        puts "signature = #{signature}"
        signature
      end

      # @param [URI::HTTP, URI::HTTPS] url
      # @return [String]
      def path(url)
        url = URI.parse(url) if url.is_a? String
        if url.path == ''
          '/'
        else
          uri_escape_path(url.path)
        end
      end

      # @param [String] path
      # @return [String]
      def uri_escape_path(path)
        path.gsub(/[^\/]+/) { |part| uri_escape(part) }
      end

      # @param [String] value
      # @return [String]
      def uri_escape(value)
        if value.nil?
          nil
        else
          CGI.escape(value.encode('UTF-8')).gsub('+', '%20').gsub('%7E', '~')
        end
      end

      # @param [Hash] params
      # @return [Array<String>]
      def cleand_dict(params)
        new_dict = {}
        params.keys.sort.each do |key|
          next if key == "Signature"
          new_dict[uri_escape(key.downcase)] = uri_escape(params[key])
        end
        new_dict
      end

      def param_list(params)
        dict = cleand_dict(params)
        dict.map { |k, v| "#{k}=#{v}" }
      end
    end
  end
end
