# frozen_string_literal: true

require "spec_helper"
require "ostruct"
require_relative '../lib/tencent_cos/auth/authorization'

module TencentCos
  module V5
    class AuthSpec
      RSpec.describe Authorization do
        it "has initialized" do
          model = Authorization.new
          model.secret_key = "BQYIM75p8x0iWVFSIgqEKwFprpRSVHlz" # 官方demo 给的sk 和ak
          model.secret_id = "AKIDQjz3ltompVjBni5LitkWHFlFpwkn9U5q"

          headers = {
            "Host" => "bucket1-1254000000.cos.ap-beijing.myqcloud.com",
            "Range" => "bytes=0-3"
          }
          params = {}
          request = OpenStruct.new(
            url: URI.parse("http://bucket1-1254000000.cos.ap-beijing.myqcloud.com/testfile"),
            method_name: "get",
            headers: headers,
            params: params
          )
          expect(model.sign(request)).to eq "q-sign-algorithm=sha1&q-ak=AKIDQjz3ltompVjBni5LitkWHFlFpwkn9U5q&q-sign-time=1417773892;1417853898&q-key-time=1417773892;1417853898&q-header-list=host;range&q-url-param-list=&q-signature=4b6cbab14ce01381c29032423481ebffd514e8be"
        end
      end
    end
  end
end
