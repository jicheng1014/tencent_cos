# frozen_string_literal: true

require 'yaml'

module TencentCos
  class Config
    ATTRS = %i[secret_id secret_key app_id region duration_seconds bucket_name request_retry timeout use_http].freeze
    attr_accessor(*ATTRS)

    def initialize(options = nil?)
      if options.nil?
        options = YAML.load_file(File.expand_path('tencent_cos.yml'))
      end
      
      ATTRS.each do |attr|
        send("#{attr}=", options[attr.to_sym])
      end

      # default values
      self.request_retry ||= 8
      self.timeout ||= 8
    end

    def host(bucket_name = nil, region = nil)
      bucket_name = self.bucket_name if bucket_name.nil?
      region = self.region if region.nil?
      # 为了解决美团证书的问题，新增的配置
      if use_http
        "http://#{bucket_name}-#{app_id}.cos.ap-#{region}.myqcloud.com"
      else
        "https://#{bucket_name}-#{app_id}.cos.ap-#{region}.myqcloud.com"
      end
    end
  end
end
