MY_NAMES = ['Alephnaut', 'Lethologica']

require 'pp'
require './source'
require './replays'
require './google_sheets'
require './game'

class Analyzer
  attr_accessor :name, :games

  def initialize(name:,games:)
    @name = name
    @games = games
  end

  def bracketed_winrates
    games
      .group_by { |game| "#{game.p2_race} (#{game.mmr_bracket})" }
      .sort
      .map { |key, games| [ key, { wins: wins(games), losses: losses(games), winrate: "#{winrate(games)}%"} ] }.to_h
  end

  def winrate(games)
    (wins(games).to_f * 100 / (wins(games).to_f + losses(games).to_f)).round(2)
  end

  def wins(games)
    games.count { |game| game.winner == name }
  end

  def losses(games)
    games.count { |game| game.winner != name }
  end
end

# source = GoogleSheets.new
source = Replays.new
# analyzer = Analyzer.new(name: MY_NAME, games: source.games)

# PP.pp(analyzer.bracketed_winrates)

PP.pp source.games