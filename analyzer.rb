require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'pp'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze

TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

SPREADSHEET_ID = '1eMzmb8dHxtmCVfBDilVIuAqs9_NGBZJ7vPw-lv60PB0'

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

def service
  @service ||= Google::Apis::SheetsV4::SheetsService.new.tap do |service|
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
  end
end

def raw_data
  range = 'A15:M'
  service.get_spreadsheet_values(SPREADSHEET_ID, range).values
end

def headers
  @headers ||= service.get_spreadsheet_values(SPREADSHEET_ID, 'A14:M14').values.first
end

def with_headers(rows)
  rows.map do |row|
    headers.zip(row)
  end
end

def formatted_games
  with_headers(raw_data).map(&:to_h)
end

def winrate(games)
  (wins(games).to_f * 100 / (wins(games).to_f + losses(games).to_f)).round(2)
end

def wins(games)
  games.count { |game| game['Result'] === 'W' }
end

def losses(games)
  games.count { |game| game['Result'] === 'L' }
end

def mmr_bracket(game)
  difference = game['My MMR'].to_i - game['Their MMR'].to_i

  if difference > -50 && difference < 50
    return '3 close             '
  elsif difference >= 200
    return '1 strongly favored  '
  elsif difference <= -200
    return '5 strongly unfavored'
  elsif difference > 0
    return '2 weakly favored    '
  else
    return '4 weakly unfavored  '
  end
end

# PP.pp formatted_games
#   .select { |game| game['Race'] === 'T' }
#   .last(40)
#   .group_by { |game| game['Opener'] }
#   .map { |opener, games| [opener, wins(games), losses(games), winrate(games)] }

PP.pp( 
  formatted_games
    .group_by { |game| "#{game['Race']} (#{mmr_bracket(game)})" }
    .sort
    .map { |key, games| [ key, { wins: wins(games), losses: losses(games), winrate: "#{winrate(games)}%"} ] }.to_h
)