# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "RubyPrintReleaseStation"
  spec.version       = '1.0'
  spec.authors       = ["Ramon Dantas"]
  spec.email         = ["pooltcc@gmail.com"]
  spec.summary       = %q{A printing release station in Ruby.}
  spec.description   = %q{A printing release station in Ruby.}
  spec.homepage      = "https://github.com/tccetecembu/ruby-print-release-station"
  spec.license       = "MIT"

  spec.files         = ['lib/utils.rb', 'lib/printing_report.rb']
  spec.executables   = ['bin/main']
  spec.test_files    = ['tests/test_printing_report.rb']
  spec.require_paths = ["lib"]
end