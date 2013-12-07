# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3_dir/version'

Gem::Specification.new do |spec|
  spec.name          = "s3_dir"
  spec.version       = S3Dir::VERSION
  spec.authors       = ["nuex"]
  spec.email         = ["nx@nu-ex.com"]
  spec.description   = %q{Upload a directory to AWS S3}
  spec.summary       = %q{Uploads a directory of files to an AWS S3 bucket}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'unf', '~> 0.1.3'
  spec.add_dependency 'fog', '~> 1.17.0'
end
