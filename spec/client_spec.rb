# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require 'timecop'
require 'byebug'
require 'vcr'
require_relative '../lib/tencent_cos/client'

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock # or :fakeweb
  config.allow_http_connections_when_no_cassette = true
end

module TencentCos
  class ClientSpec
    RSpec.describe Client do
      it 'could fetch meta' do
        client = Client.new
        VCR.use_cassette('fetch_meta') do
          response = client.fetch_meta(key: '4c33e8e91cde2680dd0cc549541d0be785a9beac.apk')
          expect(response.code).to eq 200

          expect do
            response = client.fetch_meta(key: 'not_found')
          end.to raise_error(RestClient::NotFound)
        end
        VCR.use_cassette('file_exists') do
          expect(client.key_exists?(key: '4c33e8e91cde2680dd0cc549541d0be785a9beac.apk')).to eq true
          expect(client.key_exists?(key: 'not_found')).to eq false
        end
      end

      it 'could delete file object' do
        client = Client.new
        VCR.use_cassette('delete_object') do
          response = client.delete_object(key: '4c33e8e91cde2680dd0cc549541d0be785a9beac.apk')
          expect(response.code).to eq 204
        end
      end

      it 'could list bucket correctly' do
        client = Client.new
        VCR.use_cassette('bucket_list') do
          xml = client.bucket_list
        end
      end

      it 'could build access_token for upload' do
        client = Client.new do |client|
          client.auth_helper.force_sign_time = '1417773892;1417853898' # 固定时间戳
        end

        tmp = client.upload_token('helloworld')
        expect(tmp).to eq 'q-sign-algorithm=sha1&q-ak=AKIDoYOIMWduEQgnnERYclnxBcQ3ZJ58OKeO&q-sign-time=1417773892;1417853898&q-key-time=1417773892;1417853898&q-header-list=&q-url-param-list=&q-signature=9eccc028b9414c4752d70c26aeb67d006ec77ef3'
      end

      it 'could build timspan download url' do
        client = Client.new
        Timecop.freeze(Time.at(1_509_993_031 - 30 * 60)) do
          url = client.download_url('http://pro-app-tc.fir.im/', '123.apk', expired_key: 'tencent_given_key')
          expect(url).to eq 'http://pro-app-tc.fir.im/123.apk?sign=ce0b276d23d18bf9ca0baa51b0d9bbaf&t=5a00aa47'
        end
      end

      it 'could build timspan download url' do
        client = Client.new
        VCR.use_cassette('upload_file') do
          Timecop.freeze(Time.at(1_511_260_415)) do
            url = client.upload_file(key: 'upload_text.txt', file_path: './spec/test_files/upload_text.txt')
            client.fetch_meta(key: 'upload_text.txt')
          end
        end
      end

      it 'could modify object metas' do
        begin
          client = Client.new
          
          Timecop.freeze(Time.at(1513158079)) do
            VCR.use_cassette('update_metas') do
              client.change_metas(
                key: 'upload_text.txt',
                custom_metas: { 'Content-Type' => 'application/vnd.android.package-archive' }
              )
              data = client.fetch_meta(key: 'upload_text.txt')
            end
          end
        rescue StandardError => e
        end
      end
    end
  end
end
