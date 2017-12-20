# BlueGreenWorkers

This gem provides helpers to coordiante workers across multiple clusters that for which only one cluster should be active at a time.  Think [blue green deployments](https://martinfowler.com/bliki/BlueGreenDeployment.html)

## Installation

```ruby
  gem 'blue_green_workers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blue_green_workers

## Usage

This gem doesn't attempt to provide an interface through which you specify which cluster is currently active, that's left as an exercise to the reader.  One could very easily use ActiveRecord and a simple RESTFul interface to set the current active cluster.

### Config
```ruby
BlueGreenWorkers.configure do |config|
  config.cluster_name = 'blue'
  config.determine_active_cluster { ActiveCluster.first.value }
  config.refresh_interval = 10
  config.activate { QueueClient.listen! }
  config.deactivate { QueueClient.shutdown! }
  config.logger = Logger.new STDOUT
end
```

* `cluster_name` - Defines the name for this cluster.  Something like `ENV['CLUSTER_NAME']` probably makes sense
* `determine_active_cluster` - Takes a block that returns the name of the current active cluster
* `refresh_interval` (optional) - How often to cache the active cluster in seconds, `0` (the default) will call the block passed to `determine_active_cluster` every time a worker is executed.
* `activate` (optiona) - Block to call when this cluster goes active.  Will be called during initialization.  `refresh_interval` must be specified.
* `deactivate` (optiona) - Block to call when this cluster goes passive.  This block will not be called if the cluster is started in passive mode.  `refresh_interval` must be specified.
* `logger` (optiona) - Logger to use

### Executing jobs

In addition to attaching event handles to `activate` and `deactivate` you can also do this:

```ruby
loop do
  BlueGreenWorkers.execute(opts) do
    # Do some work, poll for stuff, etc
  end
  sleep 60
end
```

Options include*
`delay` -- Delay for `n` seconds if we're not the active cluster

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hawknewton/blue_green_workers.
