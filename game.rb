class Game
  attr_accessor :winner, :p1_name, :p2_name, :p1_race, :p2_race, :p1_mmr, :p2_mmr

  def initialize(winner:, p1_name:, p2_name:, p1_race:, p2_race:, p1_mmr:, p2_mmr:)
    @winner = winner
    @p1_name = p1_name
    @p2_name = p2_name
    @p1_race = p1_race
    @p2_race = p2_race
    @p1_mmr = p1_mmr
    @p2_mmr = p2_mmr
  end

  def mmr_bracket
    difference = p1_mmr - p2_mmr

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
end