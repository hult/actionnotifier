# Action Notifier

Action Notifier is a small framework for sending push notifications in a way very
similar to [Action Mailer](https://github.com/rails/rails/tree/master/actionmailer).

## Sending push notifications

Analogous to Action Mailer, start by creating an `ApplicationNotifier` in a new
`app/notifiers` directory in your Rails project.

```ruby
class ApplicationNotifier < ActionNotifier::Base
  # ActionNotifier::Base has a method notify(app, device_token, message, custom = {})
  # so you will probably need a method that finds the (Rpush) app and the
  # device token (could also be several) to notify a given user. ActionNotifier
  # doesn't know how you store your device tokens, so you need to do the
  # translation yourself.
  #
  # The below implementation is an example where device tokens are stored in
  # a table devices(user_id, type, token) where type is the Rpush app name.
  # In the example we notify all of a user's registered devices.
  def notify(user, message, custom = {})
    user.devices.find_each do |device|
      super(Rpush::App.find_by(name: device.type), device.token, message, custom)
    end
  end
end
```

Then create notifiers much as you would mailers in Action Mailer. For example,
a social networking app may have an `app/notifiers/friend_notifier.rb`:

```ruby
class FriendNotifier < ApplicationNotifier
  def new_friend(user, friend)
    notify(user, "#{friend.name} added you as a friend!")
  end
end
```

Whenever you then want to notify the user, you do

```ruby
FriendNotifier.new_friend(user, friend)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'actionnotifier'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install actionnotifer

## Development

This section is for people who want to do development work on Action Notifier
(highly encouraged!).

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hult/actionnotifier.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
