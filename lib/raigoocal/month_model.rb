class MonthModel
  # Attributes one needs to access from the "outside"
  attr_reader :delta_start_of_weekday_from_sunday
  attr_reader :summary_teaser_length

  # Minimal json conifg for month_model example:
  # {
  #   "calendar": {
  #     "google_calendar_api_host_base_path": "https://www.googleapis.com/calendar/v3/calendars/",
  #     "calendar_id": "schau-hnh%40web.de",
  #     "api_key": "AIzaSyB5F1X5hBi8vPsmt1itZTpMluUAjytf6hI"
  #   },
  #   "month": {
  #     "summary_teaser_length_in_characters": "42",
  #     "delta_start_of_weekday_from_sunday": "1"
  #   },
  #   "general": {
  #     "maps_query_host": "https://www.google.de/maps",
  #     "maps_query_parameter": "q"
  #   }
  # }
  def initialize(json_config)
    json_parsed = JSON.parse(json_config)

    self.google_calendar_base_path = json_parsed["calendar"]["google_calendar_api_host_base_path"]
    self.calendar_id = json_parsed["calendar"]["calendar_id"]
    self.api_key = json_parsed["calendar"]["api_key"]

    self.summary_teaser_length = json_parsed["month"]["summary_teaser_length_in_characters"].to_i
    self.delta_start_of_weekday_from_sunday = json_parsed["month"]["delta_start_of_weekday_from_sunday"].to_i

    self.maps_query_host = json_parsed["general"]["maps_query_host"]
    self.maps_query_parameter = json_parsed["general"]["maps_query_parameter"]
  end

  # gets events of all kinds for the timeframe [form, to]
  def month_events(from, to)
    EventLoaderModel.get_month_events(google_calendar_base_path, calendar_id, api_key, from, to)
  end

  # gets events that are multiple day's long for the timeframe [from, to]
  def multiday_events(from, to)
    events = month_events(from, to)
    events.select { |event| event.dtstart.instance_of?(Date) }
  end

  # gets events within a day grouped by day
  def grouped_events(from, to)
    events = month_events(from, to)
    events.select { |event| event.dtstart.instance_of?(DateTime) }.sort_by{ |event| event.dtstart.localtime }.group_by { |event| event.dtstart.to_date }
  end

  # gets events that are multiple day's long grouped by the week
  def self.weeks_grouped_multiday_events(months_multiday_events, first_weekday, last_weekday)
    weeks_events = months_multiday_events.select{ |event| event.dtend > first_weekday && event.dtstart <= last_weekday }
  end

  # finds the best event, among those multiday events within a week-group, for the current day (the algorithm will find the longest events first to display them above shorter multiday events)
  def self.find_best_fit_for_day(first_weekday, day, event_heap)
    best_fit = event_heap.select{ |event| (day == first_weekday ?  (event.dtstart <= day && event.dtend >= day) : (event.dtstart == day)) }.sort_by{ |event| [event.dtstart.to_time.to_i, -event.dtend.to_time.to_i] }.first
  end

  # builds base path of current view
  def path(page_host, params = {})
    URI::HTTP.build( host: page_host, query: { v: 'm' }.merge(params).to_query).to_s
  end

  # builds path to previous/upcoming month
  def previous_path(page_path, current_shift_factor)
    month_shift_path(page_path, current_shift_factor, -1)
  end

  def upcoming_path(page_path, current_shift_factor)
    month_shift_path(page_path, current_shift_factor, 1)
  end

  def month_shift_path(page_path, current_shift_factor, shift_factor)
    path(page_path, s: (current_shift_factor.to_i + shift_factor.to_i).to_s)
  end

  # current shift factor for switching between calendar views from month to agenda
  def current_shift_for_agenda(current_shift_factor)
    today_date = Date.today
    current_shift_in_days = (MonthModel.current_month_start(current_shift_factor, today_date) - today_date).to_i

    current_shift_in_days = (MonthModel.current_month_start(current_shift_factor, today_date) + ((MonthModel.current_month_end(current_shift_factor, today_date) - MonthModel.current_month_start(current_shift_factor, today_date)).div 5) - today_date).to_i

    current_shift_factor_for_agenda = (current_shift_in_days.div AgendaModel.days_shift_coefficient)
    
    current_shift_factor_for_agenda
  end

  # current shift factor for switching between calendar views from month to month
  def current_shift_for_month(current_shift_factor)
    current_shift_factor
  end

  # helps apply styling to a special date
  def self.emphasize_date(check_date, emphasized_date, emphasized, regular)
    check_date.to_date == emphasized_date.to_date ? emphasized : regular
  end

  # depending on the cutoff conditions this will apply a cutoff style to the start of the event, the end of it, both ends or neither
  def self.multiday_event_cutoff(cutoff_start_condition, cutoff_end_condition, cutoff_start_style, cutoff_both_style, cutoff_end_style)
    if (cutoff_start_condition && cutoff_end_condition)
      cutoff_both_style
    elsif (cutoff_start_condition)
      cutoff_start_style
    elsif (cutoff_end_condition)
      cutoff_end_style
    else
      ''
    end
  end

  # build a short event summary (for popups etc.)
  def self.summary_title(event)
    event.summary.to_s.force_encoding("UTF-8") + "\n" + event.location.to_s.force_encoding("UTF-8") + "\n" + event.description.to_s.force_encoding("UTF-8")
  end

  # build a google maps path from the adress details
  def self.address_to_maps_path(address)
    URI::HTTP.build( host: maps_query_host, query: { maps_query_parameter: address.force_encoding("UTF-8").gsub(" ", "+") }.to_query).to_s
  end

  # will generate the dates of a whole week around the date given (starting from the configured day)
  def weekday_dates(today_date = Date.today)
    weekdays_dates = []
    first_day_of_week = today_date - (today_date.wday - delta_start_of_weekday_from_sunday)
    7.times do |day|
      weekdays_dates += [first_day_of_week + day]
    end
    weekdays_dates
  end

  # generates all needed dates within the start and the end of a month
  def months_view_dates(date_month_start, date_month_end)
    dates_in_month_view = []
    ((date_month_start.wday - delta_start_of_weekday_from_sunday) % 7).times do |day|
      dates_in_month_view = dates_in_month_view + [(date_month_start - (((date_month_start.wday - delta_start_of_weekday_from_sunday) % 7) - day))]
    end

    date_month_end.day.times do |day|
      dates_in_month_view = dates_in_month_view + [date_month_start + day]
    end

    (6 - date_month_end.wday + delta_start_of_weekday_from_sunday).times do |day|
      dates_in_month_view = dates_in_month_view + [date_month_end + day + 1]
    end

    dates_in_month_view
  end

  # how many weeks are within this months view dates
  def self.weeks_in_months_view_dates(months_view_dates)
    months_view_dates.length.div 7
  end

  # get date of current months start
  def self.current_month_start(current_shift_factor, today_date = Date.today)
    (today_date + (current_shift_factor.to_i).month).beginning_of_month
  end

  # get date of current months end
  def self.current_month_end(current_shift_factor, today_date = Date.today)
    (today_date + (current_shift_factor.to_i).month).end_of_month
  end

  private

  attr_writer :delta_start_of_weekday_from_sunday
  attr_writer :summary_teaser_length

  attr_accessor :calendar_id
  attr_accessor :api_key

  attr_accessor :google_calendar_base_path
  attr_accessor :maps_query_host
  attr_accessor :maps_query_parameter

end