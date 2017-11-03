module TencentCos
  module V5
    module Object
      def upload_token(file_name, custom_headers = {})
        auth(file_name, "put", {}, custom_headers)
      end
    end
  end
end