
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blue_green_workers/version'

Gem::Specification.new do |spec|
  spec.name          = 'blue_green_workers'
  spec.version       = BlueGreenWorkers::VERSION
  spec.authors       = ['hawknewton']
  spec.email         = ['hawk.newton@gmail.com']

  spec.summary       = "Deactivate background workers when we're the standby" \
  'cluster'
  spec.description = '
    Deactive any type of background worker when the cluster is standby.  This is
    useful when deploying apps that utilize timers or queues with a blue/green
    deploy strategy.
  '.strip
  spec.homepage      = 'https://github.com/hawknewton/blue_green_workers'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'null-logger'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-eventually'
  spec.add_development_dependency 'rubocop'
end
