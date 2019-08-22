require 'nokogiri'
require './game'
require './source'

class Replays
  def games
    replay_ndjson_files.map { |file_path| game_from(raw_game_data_from(file_path)) }
  end

  private
  
  def replay_ndjson_files
    Dir.glob("replays/ndjson/*")
  end

  def raw_game_data_from(file_path)
    File
      .open(file_path, "r")
      .readlines
      .first(2)
      .map { |line| JSON.parse(line)}
  end

  def race_initial(race)
    { "Zerg" => "Z", "Prot" => "P", "Terr" => "T" }[race]
  end

  def my_index(game_data)
    i_am_p1 = MY_NAMES.include? game_data[0]['Players'][0]
    i_am_p2 = MY_NAMES.include? game_data[0]['Players'][1]

    i_am_p1 ? 0 : 1
  end

  def xor(i)
    return 1 if i==0
    return 0
  end

  def game_from(game_data)
    my_index = my_index(game_data)

    p1 = game_data[0]['Players'][my_index] #should be me
    p2 = game_data[0]['Players'][xor(my_index)] #should be opponent

    p1_name = Nokogiri::HTML.parse(game_data[1]['m_playerList'][my_index]['m_name']).text
    p2_name = Nokogiri::HTML.parse(game_data[1]['m_playerList'][xor(my_index)]['m_name']).text

    Game.new(
      winner: p1['Result'] == 'Win' ? p1_name : p2_name,
      p1_name: p1_name,
      p2_name: p2_name,
      p1_race: race_initial(p1['AssignedRace']),
      p2_race: race_initial(p2['AssignedRace']),
      p1_mmr: p1['MMR'],
      p2_mmr: p2['MMR'],
    )
  end
end