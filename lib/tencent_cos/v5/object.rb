require 'digest'

module TencentCos
  module V5
    module Object
      def upload_token(file_name, custom_headers = {})
        auth(file_name, "put", {}, custom_headers)
      end
      
      # options 存在以下字段
      # expired_key 过期的expired_key 如果有这个值  就认为是私有的  否则直接返回
      # 
      def download_url(http_base, file_path, options = {})
        unless options[:expired_key].nil?
          uri_info = timespan_download_url_auth(file_path, options[:expired_key], options[:expired_second])
          return "#{http_base}#{file_path}?#{uri_info[:answer]}"
        end
        "#{http_base}#{file_path}"


      end
     
      private

      def timespan_download_url_auth(file_path, expired_key, expired_second)
        file_path = "/#{file_path}" unless file_path.start_with?('/')
        expired_second ||= 20 * 60
        # sign = MD5(KEY+ path + t)
        # http://www.test.com/ folder /vodfile.mp4?sign=abc123dsaadsasdads&t=4d024e80
        #sign=abc123dsaadsasdads&t=4d024e80
        time = Time.now.to_i + expired_second
        time_hex = time.to_s(16)
        sign = Digest::MD5.hexdigest "#{expired_key}#{file_path}#{time_hex}"
        {
          sign: sign,
          t: time_hex,
          answer: "sign=#{sign}&t=#{time_hex}"
        }
      end

    end
  end
end