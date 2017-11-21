class UrlHelper
  class << self
    def standard_url(config, uri , options = {})
    return uri if uri.start_with?("http")
    uri = "/#{uri}" unless uri.start_with?("/")
    "#{config.host(options[:bucket_name], options[:region])}#{uri}"
  end
  end
end