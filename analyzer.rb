require 'pp'
require './source'

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

source = GoogleSheets.new

PP.pp( 
  source.games
    .group_by { |game| "#{game['Race']} (#{mmr_bracket(game)})" }
    .sort
    .map { |key, games| [ key, { wins: wins(games), losses: losses(games), winrate: "#{winrate(games)}%"} ] }.to_h
)