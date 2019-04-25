# Dash Timeline Validator

This tool allows you to validate your [MPEG Dash](https://en.wikipedia.org/wiki/Dynamic_Adaptive_Streaming_over_HTTP) manifest to find if there are errors related to the presentation timeline model.

![Example](imgs/example.png)

## Docker Usage

```
docker run --rm -it anafrombr/dash_timeline_validator https://storage.googleapis.com/shaka-live-assets/player-source.mpd --verify_segments_duration false 
```

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

Run this program passing the manifest path. It can be either a URI or local path.

```
dash_timeline_validator https://storage.googleapis.com/shaka-live-assets/player-source.mpd
```

Running the program without any parameters or using `h` will show usage instruction along with optional parameters.

### Options

- `acceptable_drift *(default 2)*` - the minimum duration drift acceptable between the sequential segments
- `presentation_delay *(default 10)*` - the delay in seconds of the live edge
- `buffered_segments *(default 2)*` - the number of segments buffered by the player to generate the live edge
- `verify_segments_duration *(default false)*` - check the duration of every segment when setted to `true` (warn: this will download every segment of the manifest)
- `analyzer_folder *(default "data/[HASH]")*` - folder used to download the files
- `analyzer_manifest_path *(default "#{analyzer_folder}/manifest.mpd")*` - manifest path

Example:

```
dash_timeline_validator https://storage.googleapis.com/shaka-live-assets/player-source.mpd --acceptable_drift 2
```

### What does it validates?

1. The advised timeline segments - basically, if the `<S t=<x> d=<y>>` [is summing up right](https://github.com/globocom/dash_timeline_validator/blob/master/lib/dash_timeline_validator/segment.rb#L24-L30). Our audio segments were drifting (due to a round we made) and this made the exoplayer behave as if it were buffering while most of the other players didn't show any problem at all. It optionally [download and check whether the advised duration](https://github.com/globocom/dash_timeline_validator/blob/master/lib/dash_timeline_validator/segment.rb#L45-L64) equals to the one being served.
2. The advised timeline - if the [possible live edge is contained within the advised timeline](https://github.com/globocom/dash_timeline_validator/blob/master/lib/dash_timeline_validator/representation.rb#L34-L55) (to use client wall clock, ast, mbt, player buffer to see what should be one possible live edge)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/globocom/dash_timeline_validator.
