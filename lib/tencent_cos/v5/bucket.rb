# frozen_string_literal: true

require 'digest'

module TencentCos
  module V5
    module Bucket
      def show_objects(marker = nil, max_keys = 1000)
        url = config.host.to_s
        headers = {
          marker: marker,
          :"max-keys" => max_keys
        }.reject_if { |_k, v| v.nil? }
        do_request(url, 'get', {}, headers, auth: true)
      end
    end
  end
end
