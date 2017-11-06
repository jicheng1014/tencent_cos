# frozen_string_literal: true

require "spec_helper"
require "ostruct"
require 'timecop'
require 'byebug'
require 'vcr'
require_relative '../lib/tencent_cos/client'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end

module TencentCos
  class ClientSpec
    RSpec.describe Client do
      it 'could list bucket correctly' do
        client = Client.new
        VCR.use_cassette("bucket_list") do
          xml = client.bucket_list
        end
      end
      
      it 'could build access_token for upload' do
        client = Client.new do |client|
          client.auth_helper.force_sign_time = "1417773892;1417853898" # 固定时间戳
        end

        tmp = client.upload_token("helloworld")
        expect(tmp).to eq "q-sign-algorithm=sha1&q-ak=AKIDoYOIMWduEQgnnERYclnxBcQ3ZJ58OKeO&q-sign-time=1417773892;1417853898&q-key-time=1417773892;1417853898&q-header-list=&q-url-param-list=&q-signature=9eccc028b9414c4752d70c26aeb67d006ec77ef3"
      end
      
      it 'could build timspan download url' do
        client = Client.new 
        Timecop.freeze(Time.at(1509948410)) do
          url = client.download_url("https://pro-app-tx.fir.im/", 'test.apk', expired_key: "whosyourdaddy")
          puts url
          expect(url.include?("sign=")).to eq true
        end

      end

    end
  end
end
