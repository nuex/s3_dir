require_relative 's3_dir/version'
require 'fog/aws/storage'
require 'digest/md5'

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
    uploader = Uploader.new(dir, key, options)
    uploader.upload
  end

  class Uploader
    attr_reader :key
    attr_reader :bucket
    attr_reader :storage
    attr_reader :is_public
    attr_reader :files_path

    def initialize dir, key, options
      @files_path = File.expand_path(dir)

      # Merge defaults with passed-in options
      settings = {credential: ENV['FOG_CREDENTIAL'],
                  private: false}.merge(options)

      # Configure Fog
      Fog.credential = settings[:credential]

      # Get a region
      region = Fog.credentials[:region] || 'us-west-2'

      # If we don't specify this endpoint, Fog will complain about
      # not using the correct endpoint if the bucket has dots in
      # the name (i.e. website bucket)
      endpoint = 'http://s3.amazonaws.com'

      # This may be a public bucket
      @is_public = !settings[:private]

      # Set up our storage object
      # We have to specify path_style here because Fog will complain about
      # our website bucket (if we're using a bucket with dots in the name)
      # not being covered by the SSL certificate.
      fog_options = Fog.credentials.merge({provider: 'aws', path_style: true,
                                           region: region, endpoint: endpoint})
      fog_options.delete(:key_name)
      @storage = Fog::Storage.new(fog_options)
      @bucket = storage.directories.get(key)
      @bucket ||= storage.directories.create(key: key, public: is_public)
      @key = key
    end

    def upload
      Dir.chdir(files_path) do
        Dir['**/*'].each do |entry|
          File.directory?(entry) ? create_directory(entry) : create_file(entry)
        end
      end
    end

    private

    def create_directory entry
      bucket.files.create(key: entry, public: is_public)
    end

    def create_file entry
      storage.head_object(key, entry, {'If-None-Match' => md5(entry)})
    rescue Excon::Errors::NotFound
      bucket.files.create(key: entry, public: is_public, body: File.open(entry))
    end

    def md5 entry
      Digest::MD5.digest(entry)
    end
  end
end
