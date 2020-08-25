# frozen_string_literal: true

require_relative 'individual.rb'
require_relative 'position.rb'
require_relative 'genotype.rb'
require_relative 'phenotype.rb'
require_relative 'food.rb'

class World
  def initialize(size, load_individuals)
    Position.inject_size(size)
    @size = size
    @individuals = []
    @food_points = []

    @new_individuals = []
    @dead_individuals = []

    init_individuals(load_individuals)
    init_food
  end

  def init_individuals(to_load_individuals)
    if to_load_individuals
      individuals = IndividualsLoader.load
      populate_the_world(individuals)
    else
      add_random_individuals(S.individuals_number)
    end
  end

  def populate_the_world(individuals)
    @individuals = individuals.map do |ind|
      Individual.new(@world_size, position: ind[:position], genotype: ind[:genotype], phenotype: ind[:phenotype])
    end
  end

  def init_food
    add_random_food_points(S.food_points_number)
  end

  def update
    update_individuals_list
    @individuals.each do |ind|
      # ind.set_near_individuals(near_individuals(ind))
      # ind.set_near_food(near_food(ind))
      ind.update(self)
      reproduction_pair = ind.get_reproduction_pair
      generate_new_individual(reproduction_pair) if reproduction_pair
      kill_individual(ind) if ind.is_dead
    end
    @food_points.each(&:update)
    @food_points = @food_points.find_all { |fp| !fp.empty? }
  end

  def near_individuals(individual)
    near_individuals = @individuals.find_all do |ind|
      individual.in_view_scope?(ind) unless individual.equal?(ind)
    end
    near_individuals.empty? ? nil : near_individuals
  end

  def near_food(individual)
    near_food = @food_points.find_all { |fp| individual.in_view_scope?(fp) }
    near_food.empty? ? nil : near_food
  end

  def draw
    @individuals.each(&:draw)
    @food_points.each(&:draw)
  end

  def add_random_individuals(count)
    count.times do
      @individuals << Individual.new(@size)
    end
  end

  def add_random_food_points(count)
    count.times do
      @food_points << Food.new(Position.new(Random.rand(@size.w), Random.rand(@size.h)))
    end
  end

  def generate_new_individual(pair)
    genotype = Genotype.genotype_crossing(pair[0].genotype, pair[1].genotype)
    position = Position.new(pair.first.position.x, pair.first.position.y)
    @new_individuals << Individual.new(@size, position: position, genotype: genotype)
  end

  def kill_individual(ind)
    @dead_individuals << ind
  end

  def update_individuals_list
    if @new_individuals.any?
      @individuals += @new_individuals
      @new_individuals = []
    end
    if @dead_individuals.any?
      @individuals -= @dead_individuals
      @dead_individuals = []
    end
  end
end
