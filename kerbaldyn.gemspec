require File.join(File.dirname(__FILE__), 'lib', 'kerbaldyn', 'version')

Gem::Specification.new do |s|
  s.name = 'kerbaldyn'
  s.version = KerbalDyn::VERSION

  s.authors = ['Jeff Reinecke']
  s.email = 'jeff@paploo.net'
  s.homepage = 'http://www.github.com/paploo/kerbal-dyn'
  s.summary = 'A library for Kerbal Space Program (KSP) calculation and simulation tools.'
  s.description = 'A library for Kerbal Space Program (KSP) calculation and simulation tools.'
  s.licenses = ['BSD']

  s.required_ruby_version = '>=1.9.0'
  s.require_paths = ['lib']
  s.files = Dir[
    'README.rdoc',
    'Rakefile',
    'Gemfile',
    'LICENSE',
    'lib/**/*',
    'bin/**/*',
    'spec/**/*',
    '.rspec',
    '*.gemspec'
  ]

  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc']
end
