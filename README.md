# Raigoocal

This gem contains a few helpful functions that help load google calendar events and orgenize them into an agenda or month wise optimized data model that then can be used to easily display those events in a view.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'raigoocal'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install raigoocal

## Usage

The gem consists of mainly three models. One the event loader model is focusing on loading the events from the google server via a restfull api and an api key. The other two are the agenda and month model wich offer functionality to organize the data for an agenda or month view.

The main steps to use this gem are:
- Initialize an agenda or month model object with a json config that specifies these values:
````
{
  "calendar": {
    "google_calendar_api_host_base_path": "https://www.googleapis.com/calendar/v3/calendars/",
    "calendar_id": "schau-hnh%40web.de",
    "api_key": "AIzaSyB5F1X5hBi8vPsmt1itZTpMluUAjytf6hI"
  },
  "agenda": {
    "display_day_count": "14",
    "days_shift_coefficient": "7"
  },
  "month": {
    "summary_teaser_length_in_characters": "42",
    "delta_start_of_weekday_from_sunday": "1"
  },
  "general": {
    "maps_query_host": "https://www.google.de/maps",
    "maps_query_parameter": "q"
  }
}
````
- It would be possible to leave out either the agenda or month node if you only need the functionality of the other one.
- The node "calendar" holds all relevant information to the chosen calendar that you want to load events from.
- Under "general" there is the "maps_query_host" wich is the base url to a map service (like google maps in this example) and the "maps_query_parameter". (Maybe in the future there will be more map services, that let one search for a location just via the url and a parameter. But for now i only found gmaps to be able to do this. Like: https://www.google.de/maps/?q=Dresden+Hauptbahnhof)
- In "agenda" you can set the span "display_day_count" of day's considered/loaded in one view and by how many day's it will be shifted "days_shift_coefficient".
- In "month" you can set the "summary_teaser_length_in_characters" and in your view you can truncate the title to that length to reduce the size of the seperate events not to become to big in the view. The "delta_start_of_weekday_from_sunday" can be set to whatever value you need to have the week start at another day than sunday. (Like 1 -> Monday)

Then once configured you can load the events inside of the current timeframe and then use the other functionality to display them nicely.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at this repository.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
