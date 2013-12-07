require_relative 's3_dir/version'
require 'fog/aws/storage'

# S3Dir uploads files to S3
#
# S3Dir assumes your credentials are in `~/.fog`. Pass
# the credential argument with the namespace of your
# credentials in the `.fog` file.
#
# ## Usage:
#
#     require 's3_dir'
#
#     dir = '/path/to/upload'
#     bucket = 's3-website.com'
#
#     S3Dir.upload(dir, bucket, credential: :s3-website)
#
# Options include:
#
#   `credential` default ENV['FOG_CREDENTIAL']
#     Namespace for AWS credentials in the `.fog` file
#
#   `private` default false
#     Setting private to true will make the bucket and all
#     of its contents not public.
#
module S3Dir
  # Upload files to S3 
  def self.upload dir, key, options={}
    files_path = File.expand_path(dir)

    # Merge defaults with passed-in options
    settings = {credential: ENV['FOG_CREDENTIAL'],
                private: false}.merge(options)

    # We have to manually extract fog credentials here
    # because we'll need those settings when creating a new
    # Fog::Storage object with custom settings
    all_credentials = YAML::load_file(File.join(ENV['HOME'], '.fog'))
    credential = settings[:credential]
    credentials = all_credentials[credential]
    access_key = credentials[:aws_access_key_id]
    secret_key = credentials[:aws_secret_access_key]
    region = credentials[:region] || 'us-west-2'

    # If we don't specify this endpoint, Fog will complain about
    # not using the correct endpoint if the bucket has dots in
    # the name (i.e. website bucket)
    endpoint = 'http://s3.amazonaws.com'

    # This may be a public bucket
    is_public = !settings[:private]

    # Set up our storage object
    # We have to specify path_style here because Fog will complain about
    # our website bucket (if we're using a bucket with dots in the name)
    # not being covered by the SSL certificate.
    storage = Fog::Storage.new(provider: 'aws', aws_access_key_id: access_key,
                               aws_secret_access_key: secret_key,
                               path_style: true, region: region,
                               endpoint: endpoint)
    bucket = storage.directories.get(key)
    bucket ||= storage.directories.create(key: key, public: is_public)

    Dir.chdir(files_path) do                                                                     Dir['**/*'].each do |entry|
        if File.directory?(entry)
          bucket.files.create(key: entry, public: is_public)
        else
          bucket.files.create(key: entry, public: is_public, body: File.open(entry))
        end
      end
    end
  end
end
