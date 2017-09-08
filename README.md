# KohaIls

This gem allows you to integrate Koha into your Ruby based library system by wrapping its ILSDI API and its responses in Ruby objects.

## Why not use koha gem?

The [koha gem](https://rubygems.org/gems/koha) is built around the Koha REST API, however our vendor's advice was not to use the REST API and for this reason we use the standard ILSDI API. If you are using the REST interface, you should probably use the koha gem.

# Features

KohaIls provides method wrappers around most calls to ILSDI api and Ruby classes to wrap the responses to these calls. It also provides a wrapper around the OPAC login and fine payment API. The classes returned from the ILSDI API provide a ruby-ish API for the ILSDI response XML using `sax_machine`.

## Configuration

There are several configuration options depending on which features you are using. At minimum, you will need to configure the `base_path` for your Koha installation. If you are using the gem to handle payments, you will need to specify a `payments_user` and a `payments_password` for the user you have created to handle payments. If you are using Rails, you can put this configuration into an initializer as follows.

```ruby
# config/initializers/koha_ils.rb

KohaIls.configure do |config|
  # config.base_path = "http://koha.library.dk"

  # config.payments_user = '999'
  # config.payments_password = 'secretpassword'

  # config.observers = [ APIMonitor.instance ]
end

```

If you want to monitor Koha API usage and performance, you can also configure `observers`, which will hook into ILSDI requests using the Observer pattern. An example observer might look like this:

```ruby
class APIMonitor
  # Ensures all updates are processed through a single object
  include Singleton

  def update(query, duration)
    Rails.logger.info "Koha request: #{query} took #{duration}"
  end
end
```

# Usage

```
$ bin/console
irb> KohaIls.configuration.base_path = "http://catalogue-koha-staging.dtic.dk/"
irb> p = KohaIls.get_patron_info('999')
=> #<KohaIls::Patron>
irb> p.fines
=> [#<KohaIls::Fine]
irb> p.reservations
=> [#<KohaIls::Reservation]
irb> p.loans
=> [#<KohaIls::Loan]
irb> recs = KohaIls::ILSDI.get_records([1, 2, 3]).records
=> [#<KohaIls::Records]
irb> recs.first.items
=> [#<KohaIls::Item>]
irb> av = KohaIls.get_availability([209])
=> #<KohaIls::AvailabilityResponse @records=[#KohaIls::AvailabilityRecord]>
...etc
```
See `lib/koha_ils/ilsdi.rb` for full details.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dtulibrary/koha_ils. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

