# Action Pusher

Action Pusher is a small framework for sending push notifications in a way very
similar to [Action Mailer](https://github.com/rails/rails/tree/master/actionmailer).

## Sending pushes

Analogous to Action Mailer, start by creating an `ApplicationPusher` in a new
`app/pushers` directory in your Rails project.

```ruby
class ApplicationPusher < ActionPusher::Base
  # ActionPusher::Base has a method push(app, device_token, message, custom = {})
  # so you will probably need a method that finds the (Rpush) app and the
  # device token (could also be several) to push to for a given user. ActionPusher
  # doesn't know how you store your device tokens, so you need to do the
  # translation yourself.
  #
  # The below implementation is an example where device tokens are stored in
  # a table devices(user_id, type, token) where type is the Rpush app name.
  # In the example we push to all of a user's registered devices.
  def push(user, message, custom = {})
    user.devices.find_each do |device|
      super(Rpush::App.find_by(name: device.type), device.token, message, custom)
    end
  end
end
```

Then create pushers much as you would mailers in Action Mailer. For example,
a social networking app may have an `app/pushers/friend_pusher.rb`:

```ruby
class FriendPusher < ApplicationPusher
  def new_friend(user, friend)
    push(user, "#{friend.name} added you as a friend!")
  end
end
```

Whenever you then want to push to the user, you do

```ruby
FriendPusher.new_friend(user, friend)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'actionpusher'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install actionpusher

## Development

This section is for people who want to do development work on Action Pusher
(highly encouraged!).

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hult/actionpusher.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
