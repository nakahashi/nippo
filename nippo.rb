#! /bin/sh
exec ruby -S -x "$0" "$@"
#! ruby

require "bundler/setup"
Bundler.require
require 'active_support/time'

require "optparse"

option = {}
OptionParser.new do |opt|
  opt.on('-s [mm/dd]', '今日の日付（省略可）') {|v| option[:start_date] = v}
  opt.on('-e [mm/dd]', '明日の日付（省略可）') {|v| option[:end_date] = v}

  opt.parse!(ARGV)
end

def create_date_from_param(param_date)
  date_array = param_date.split("/")
  Time.parse("#{Time.now.year}/#{date_array[0]}/#{date_array[1]}")
end

if option[:start_date]
  start_date = create_date_from_param(option[:start_date])
else
  start_date = Time.now
end

if option[:end_date]
  end_date = create_date_from_param(option[:end_date])
else
  end_date = start_date.tomorrow
end

require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'nippo'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

# Initialize the API
service = Google::Apis::CalendarV3::CalendarService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# これでカレンダーの一覧を取得して、イベント取得時に使う
# service.list_calendar_lists.items.each do |item|
#   puts item.summary
# end

# Fetch the next 10 events for the user
calendar_id = 'hoge@example.com'

today_items = service.list_events(calendar_id,
                               single_events: true,
                               time_min: start_date.beginning_of_day.iso8601,
                               time_max: start_date.end_of_day.iso8601,
                               order_by: 'startTime').items
tomorrow_items = service.list_events(calendar_id,
                               single_events: true,
                               time_min: end_date.beginning_of_day.iso8601,
                               time_max: end_date.end_of_day.iso8601,
                               order_by: 'startTime').items

if option[:end_date]
  tomorrow_name = end_date.strftime("%m/%d")
else
  tomorrow_name = "明日"
end

require "./hitokoto"
hitokoto = fetch_hitokoto

require 'erb'
nippo_erb = ERB.new(File.read("nippo.md.erb"), nil, "-")
nippo_erb.run
