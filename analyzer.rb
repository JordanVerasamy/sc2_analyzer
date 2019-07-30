require 'pp'
require './source'
require './game'

MY_NAME = 'Alephnaut'

def winrate(name, games)
  (wins(name, games).to_f * 100 / (wins(name, games).to_f + losses(name, games).to_f)).round(2)
end

def wins(name, games)
  games.count { |game| game.winner == name }
end

def losses(name, games)
  games.count { |game| game.winner != name }
end

def mmr_bracket(name, game)
  difference = game.p1_mmr.to_i - game.p2_mmr.to_i

  if difference > -50 && difference < 50
    return 'close                '
  elsif difference >= 200
    return 'p1 strongly favored  '
  elsif difference <= -200
    return 'p2 strongly unfavored'
  elsif difference > 0
    return 'p1 weakly favored    '
  else
    return 'p2 weakly unfavored  '
  end
end

source = GoogleSheets.new

PP.pp( 
  source.games
    .group_by { |game| "#{game.p2_race} (#{mmr_bracket(MY_NAME, game)})" }
    .sort
    .map { |key, games| [ key, { wins: wins(MY_NAME, games), losses: losses(MY_NAME, games), winrate: "#{winrate(MY_NAME, games)}%"} ] }.to_h
)