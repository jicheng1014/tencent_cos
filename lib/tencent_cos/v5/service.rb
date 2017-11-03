module TencentCos
  module V5
    module Service
      def bucket_list
        do_request("http://service.cos.myqcloud.com", "get", {},{} ,auth: true)
      end
    end
  end
end