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
end