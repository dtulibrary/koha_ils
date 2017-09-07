# KohaIls

This gem allows you to integrate Koha into your Ruby based library system by wrapping its ILSDI API and its responses in Ruby objects.

## Why not use koha gem?

This gem does not use the Koha REST interface as our vendor's advice was to use the ILSDI API exclusively. If you are using the REST interface, you should probably use the koha gem.

# Features

Wrappers around most calls to ILSDI api and Ruby classes to wrap the responses to these calls.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'koha_ils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install koha_ils

## Configuration

To use the KohaIls gem you must first configure the base path of the installation. To do this, use an initializer:

```ruby
# config/initializers/koha_ils.rb

KohaIls.configure do |config|
  config.base_path = "http://koha.library.dk"
  # config.observers = [ APIMonitor.instance ]
end

```
The wrapper allows for performance monitoring of API requests using the Observer pattern. You can register your observer as above, an example observer might look like this:


class APIMonitor
  include Singleton

  def update(query, duration)
    Rails.logger.info "Koha request: #{query} took #{duration}"
  end
end

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/koha_ils. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

