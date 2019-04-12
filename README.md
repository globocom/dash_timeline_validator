# Dash Timeline Validator

An MPEG Dash timeline validator. The validator parses the given MPD file (local or from the web) and shows information and errors of the timeline.

![Example](imgs/example.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dash_timeline_validator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dash_timeline_validator

## Usage

Run this program passing the manifest path.

```
dash_timeline_validator https://storage.googleapis.com/shaka-live-assets/player-source.mpd
```

To download and check the duration of every chunk, use the environment variable `VERIFY_SEGMENTS_DURATION` as `true`.

```
VERIFY_SEGMENTS_DURATION=true dash_timeline_validator https://storage.googleapis.com/shaka-live-assets/player-source.mpd
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/globocom/dash_timeline_validator.
