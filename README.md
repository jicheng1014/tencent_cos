# TencentCos

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/tencent_cos`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tencent_cos', git: "https://github.com/jicheng1014/tencent_cos.git"
```

And then execute:

    $ bundle

## Usage

###Init client
```ruby
client = TencentCos::Client.new(
        secret_id: "your secret_id",
        secret_key: "your key",
        app_id: "your app_id",
        region: "Benjing",
        bucket_name: "bucket_name",
        request_retry: 2,
        timeout: 30
    )
```

###get auth
```ruby
auth = client.upload_token(params[:key])
```

###get host
```ruby
host = client.config.host
```

###delete object
// bucket&region if empty, value is default config
```ruby
client.delete_object({
        key: "xxxx",
        bucket: "xxxx",
        region: "xxx"
})
```


###file exists? 
```ruby
client.key_exists({key: "xxxx",
                   bucket: "xxxx",
                   region: "xxx"})
```



