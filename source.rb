require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './game'

class Source
  def games
    raise NotImplementedError
  end
end

class GoogleSheets < Source
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'SC2 Analyzer'.freeze
  CREDENTIALS_PATH = 'credentials.json'.freeze

  TOKEN_PATH = 'token.yaml'.freeze
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

  SPREADSHEET_ID = '1eMzmb8dHxtmCVfBDilVIuAqs9_NGBZJ7vPw-lv60PB0'

  def games
    game_hashes.map { |game_hash| game_from(game_hash) }
  end

  private

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

  def game_hashes
    with_headers(raw_data).map(&:to_h)
  end

  def game_from(game_hash)
    my_name = 'Alephnaut'
    their_name = game_hash['Name']
    my_race = 'T'
    their_race = game_hash['Race']
    my_mmr = game_hash['My MMR']
    their_mmr = game_hash['Their MMR']

    Game.new(
      winner: game_hash['Result'] == 'W' ? my_name : their_name,
      p1_name: my_name,
      p2_name: their_name,
      p1_race: my_race,
      p2_race: their_race,
      p1_mmr: my_mmr,
      p2_mmr: their_mmr,
    )
  end
end