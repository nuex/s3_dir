S3Dir
=====

Quickly upload a directory and its contents to s3.

## Installation

Add this line to your application's Gemfile:

    gem 's3_dir'

And then execute:

    $ bundle

You'll need to configure your `fog` AWS credentials in `~/.fog`:

    :aws_credentials:
      :aws_access_key_id: AWS_ACCESS_KEY
      :aws_secret_access_key: AWS_SECRET_ACCESS_KEY

## Usage

    require 's3_dir'

    path = '/path/to/upload'
    bucket = 'mybucket'
    S3Dir.upload(path, bucket, credential: :aws_credentials)

### Configuration Options

`credential` default ENV['FOG_CREDENTIAL']
   Namespace for AWS credentials in the `.fog` file

`private` default false
   Setting private to true will make the bucket and all
   of its contents not public.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
