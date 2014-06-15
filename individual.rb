require 'texplay'
require_relative 'game_object.rb'
require_relative 'position.rb'
require_relative 'phenotype.rb'
require_relative 'genotype.rb'
require_relative 'util.rb'


class Individual < GameObject

  include Util

  attr_reader :genotype, :phenotype, :need_to_update_sprite,
              :reproduction_pair, :is_dead

  def self.new(*args, &block)
    @index ||= -1
    @index += 1
    new_args = [@index] + args
    obj = self.allocate
    obj.send :initialize, *new_args, &block
    obj
  end

  def to_s
    "<#{@id} at #{@position}>:#{@phenotype.size}"
  end

#  def inspect
#    "#{@id}, #{@position}, #{@genotype}, #{@phenotype}"
#  end

  def update
    if !in_reproduction?
      make_decision
      process_view
      @is_moving = moving
    else
      @is_moving = false
    end
    @phenotype.update @genotype, @is_moving
    update_sprite if @phenotype.update_sprite?
  rescue DyingFromStarving
    @is_dead = true

  end

  def set_near_individuals(near_individuals)
    @near_individuals = near_individuals
  end

  def set_near_food(near_food)
    @near_food = near_food
  end

  def in_view_scope?(obj)
    if obj.instance_of?(Individual)
      (@position.range(obj.position) - obj.phenotype.absolute_size / 2) <= @phenotype.view_scope
    else
      @position.range(obj.position) <= @phenotype.view_scope
    end
  end

  def reproduction_proposal(pair)
    if suitable_individual pair
      log 'Im passive!'
      @passive = true
      @pair = pair
      @in_reproduction = true
      true
    else
      false
    end
  end

  def get_reproduction_pair
    return nil if @reproduction_pair.empty?
    temp = @reproduction_pair
    @reproduction_pair = []
    return temp
  end

  protected

  def initialize(id, window, world_size, position, genotype, phenotype)
    super(window, world_size, position, PALETTE_PATH)
    @id = id
    @genotype = genotype
    @phenotype = phenotype

    @need_to_update_sprite = false
    @want_to_eat = false
    @want_to_reproduct = false
    @is_moving = false
    @current_target = nil
    @current_search_point = nil

    @just_reproducted = false
    @iterations_after_reproduction = 0

    @in_reproduction = false
    @iterations_in_reproduction = 0
    @reproduction_pair = []

    @active = false
    @passive = false

    @is_dead = false

    update_sprite
  end

  def need_to_update_sprite?
    if @need_to_update_sprite
      @need_to_update_sprite = false
      return true
    end
    false
  end

  def update_sprite
    @sprite = @empty_image.clone
    size = @phenotype.absolute_size
    color = @phenotype.color
    log 'Updating image !'
    @sprite.paint{
      circle(IMAGE_SIZE / 2, IMAGE_SIZE / 2, size, :color => color)
    }
  end

  def have_business?
    @want_to_eat || @want_to_reproduct
  end

  def make_decision
    set_hungry_status
    set_reproduction_state
  end

  def set_hungry_status
    if @phenotype.satiety <= HUNGRY_BORDER
      log "Want to eat (#{@phenotype.satiety})" unless @want_to_eat  #talk about food only at first time
      @want_to_eat = true
    else
      @want_to_eat = false # Не хочет есть
    end
  end

  def set_reproduction_state
    if @phenotype.age > @genotype.reproduction_gene
      if @just_reproducted #только что размножалась, и соответсвенно больше не хочет (сейчас)
        @iterations_after_reproduction += 1
        if @iterations_after_reproduction == ITERATIONS_AFTER_REPRODUCTING
          @just_reproducted = false
          @iterations_after_reproduction = 0
        end
      elsif !@want_to_reproduct
        @want_to_reproduct = true if happens_with_probability? AGE_MUTATION_PROBABILITY
        log "Want to reproduct (#{@phenotype.age})" if @want_to_reproduct
      end
    end
  end

  def generate_random_target
    target = Position.new(Random.rand(@world_size.w), Random.rand(@world_size.h))
    puts "Generate target = #{@position} -> #{target}, searching..."
    target
  end

  def process_view
    return false if target_is_object? || !have_business?
    food = most_appropriate_food if @want_to_eat
    pair = most_appropriate_pair if @want_to_reproduct
    return false if !food && !pair
    set_target food, pair
  end

  def set_target(food, pair)
    priority = desire_priority
    if priority == Food || priority == nil
      @target = food || pair
    elsif priority == Individual
      @target = pair || food
    else
      raise ArgumentError, 'Unsupported target type'
    end
    log "My target is [#{@target}]"
  end

  def desire_priority
    if @phenotype.satiety < STARVING_BORDER
      Food
    elsif @want_to_reproduct
      Individual
    else
      nil
    end
  end

  def moving
    return false unless have_business?
    if target_reached?
      make_action
      return false
    end
    @target = generate_random_target if @target.nil?

    @position.move @target, @phenotype.speed
    true
  end

  def target_reached?
    @position == @target if @target
  end

  def make_action
    if @target.instance_of? Position
      log 'Just nothing here'
      @target = nil
    elsif @target.instance_of? Individual
      log 'This is individual'
      reproduction_stage
      @target = nil
    elsif @target.instance_of? Food
      log 'This is food point !'
      eat_transaction
      @target = nil
    end
  end

  def reproduction_stage
    log 'Here, reproduction stage!'
    unless @passive
      log 'Im active!'
      @active = true
      answer = @target.reproduction_proposal self
      if answer
        @pair = @target
        @in_reproduction = true
      else
        log "Reproduction rejected from #{@target}"
        @active = false
      end
    else
      log "Have proposal from #{@target}"
    end
  end

  def eat_transaction
    owner = @target.get_owner
    if owner == self || owner == nil || !owner.stronger?(@phenotype.strength)
      log "Eating #{@target} : #{owner} is weakly" if owner.class == Individual
      feeding_operation if @target.try_to_eat self
    else
      log "Can't eat #{@target} : #{owner} is stronger"
    end
  end

  def feeding_operation
    old_satiety = @phenotype.satiety
    @phenotype.satiety += FOOD_PER_POINT
    log "I got food #{old_satiety} --> #{@phenotype.satiety}"
  end

  def closest_object(objects_arr)
    if objects_arr.size == 1
      closest_obj = objects_arr.first
    else
      obj_range_hash = create_obj_range_hash objects_arr
      closest_obj = obj_range_hash.max_by {|k, v| v}.first
    end
    log "Closest #{closest_obj.class} is #{closest_obj}"
    closest_obj
  end

  def create_obj_range_hash(objects_arr)
    objects_arr.reduce({}) do |result, elem|
      result[elem] = range elem
      result
    end
  end

  def most_appropriate_food
    puts "#{self} see -> #{@near_food}" if @near_food
    @near_food ? closest_object(@near_food) : nil
  end

  def most_appropriate_pair
    puts "#{self} see -> #{@near_individuals}" if @near_individuals
    @near_individuals ? closest_object(@near_individuals) : nil  #most atractive
  end

  def target_is_object?
    @target && !@target.instance_of?(Position)
  end

  def stronger?(strength)
    @phenotype.strength > strength
  end

  def suitable_individual(potential_pair)
    if @want_to_reproduct
      true
    else
      false
    end
  end

  def in_reproduction?
    return false unless @in_reproduction
    @iterations_in_reproduction += 1
    if @iterations_in_reproduction == REPRODUCTION_PHASE_TIME
      if @active  #real pair generating only at end of reproduction
        @reproduction_pair = [self, @pair]
      end
      @pair = nil
      @want_to_reproduct = false
      @just_reproducted = true
      @in_reproduction = false
      @iterations_in_reproduction = 0
      @active = false
      @passive = false
      log "Finished reproduction"
    end
    true
  end

end
