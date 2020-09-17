# frozen_string_literal: true

class World
  def initialize(load_individuals)
    @individuals = init_individuals(load_individuals)
    @food_points = init_food_points

    @new_individuals = []
    @dead_individuals = []
  end

  def draw
    @individuals.each(&:draw)
    @food_points.each(&:draw)
  end

  def update
    update_individuals_list
    @individuals.each do |ind|
      ind.near_individuals = near_individuals(ind)
      ind.near_food = near_food(ind)
      ind.update(self)
      reproduction_pair = ind.get_reproduction_pair
      generate_new_individual(reproduction_pair) if reproduction_pair
      kill_individual(ind) if ind.is_dead
    end
    @food_points.each(&:update)
    @food_points = @food_points.find_all { |fp| !fp.empty? }
  end

  private def init_individuals(load_individuals)
    if load_individuals
      IndividualsLoader.load.map do |ind|
        Individual.new(position: ind[:position],
                       genotype: ind[:genotype],
                       phenotype: ind[:phenotype])
      end
    else
      (1..S.individuals_amount).map { Individual.new }
    end
  end

  private def init_food_points
    (1..S.food_points_number).map { Food.new(Rand.position) }
  end

  private def near_individuals(individual)
    individuals = @individuals.find_all do |ind|
      individual.in_view_scope?(ind) unless individual.equal?(ind)
    end
    individuals.empty? ? nil : individuals
  end

  private def near_food(individual)
    near_food = @food_points.find_all { |fp| individual.in_view_scope?(fp) }
    near_food.empty? ? nil : near_food
  end

  private def generate_new_individual(pair)
    genotype = Genotype.genotype_crossing(pair[0].genotype, pair[1].genotype)
    position = Position.new(pair.first.position.x, pair.first.position.y)
    @new_individuals << Individual.new(position: position, genotype: genotype)
  end

  private def kill_individual(ind)
    @dead_individuals << ind
  end

  private def update_individuals_list
    if @new_individuals.any?
      @individuals += @new_individuals
      @new_individuals.clear
    end
    if @dead_individuals.any?
      @individuals -= @dead_individuals
      @dead_individuals.clear
    end
  end
end
