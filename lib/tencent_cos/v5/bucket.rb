# frozen_string_literal: true

require 'digest'
require 'nokogiri'

module TencentCos
  module V5
    module Bucket
      def show_objects(marker = nil, max_keys = 1000)
        url = config.host.to_s
        dict = {
          "marker" =>  marker,
          "max-keys" => max_keys
        }.reject { |_k, v| v.nil? }
        params_str = dict.map { |key, val| "#{key}=#{val}"}.join('&')

        response = do_request("#{url}?#{params_str}", 'get', {}, {}, auth: true)
        xml = Nokogiri.parse(response.body)

      end

      def all_objects
        called_info = show_objects()
        yield(called_info) if block_given?
        answer = []
        while called_info.at_css("IsTruncated").text == "true"
          sleep 0.1
          next_marker = called_info.at_css("NextMarker").text
          called_info.css("Key").map {|x| x.text}.each {|x| answer << x}
          puts "answer count = #{answer.count}"
          called_info = show_objects(next_marker)
          yield(called_info) if block_given?
        end
        answer
      end

    end
  end
end
