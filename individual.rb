require 'texplay'
require_relative 'game_object.rb'
require_relative 'position.rb'
require_relative 'phenotype.rb'
require_relative 'genotype.rb'
require_relative 'util.rb'


class Individual < GameObject

  include Util

  attr_reader :genotype, :phenotype, :need_to_update_sprite

  def self.new(*args, &block)
    @index ||= -1
    @index += 1
    new_args = [@index] + args
    obj = self.allocate
    obj.send :initialize, *new_args, &block
    obj
  end

  def to_s
    "<#{@id} at #{@position}>"
  end

#  def inspect
#    "#{@id}, #{@position}, #{@genotype}, #{@phenotype}"
#  end

  def update
    make_decision
    process_view
    is_moving = moving
    @phenotype.update @genotype, is_moving
    update_sprite if @phenotype.update_sprite?
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

  protected

  def initialize(id, window, world_size, position, genotype, phenotype)
    super(window, world_size, position, PALETTE_PATH)
    @id = id
    @genotype = genotype
    @phenotype = phenotype

    @need_to_update_sprite = false
    @target = nil
    @to_find_food = false
    @to_find_pair = false
    @is_moving = false
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
    # TODO: add attractiveness to circle morph
    @sprite = @empty_image.clone
    size = @phenotype.absolute_size
    color = @phenotype.color
    log 'Updating image !'
    @sprite.paint{
      circle(IMAGE_SIZE / 2, IMAGE_SIZE / 2, size, :color => color)
    }
  end

  def have_business?
    @to_find_food || @to_find_pair
  end

  def make_decision
    check_hungry_status
    check_reproduction_state
  end

  def generate_random_target
    target = Position.new(Random.rand(@world_size.w), Random.rand(@world_size.h))
    puts "Generate target = #{@position} -> #{target}, searching..."
    target
  end

  def process_view
    return false if !have_business? || target_is_object?
    food = most_appropriate_food
    pair = most_appropriate_pair
    return false if !food && !pair
    set_target food, pair
  end

  def set_target(food, pair)
    priority = desire_priority
    if priority == Food
      @target = food
      @target = pair unless @target
    elsif priority == Individual
      @target = pair
      @target = food unless @target
    else
      log 'Unsupported target type' #TODO rewrite as exception
    end
    log "My target is [#{@target}]"
  end

  def desire_priority
    if @phenotype.satiety < STARVING_BORDER
      Food
    else
      Individual #TODO change
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
      # log 'This is my in!'
      # TODO we need to make new individual here
    elsif @target.instance_of? Food
      log 'This is food point !'
      if @target.eat
        log "I got food #{@phenotype.satiety} -->"
        @phenotype.satiety += FOOD_PER_POINT
        log "--> #{@phenotype.satiety}"
      end
      log 'Need to go'
      @target = generate_random_target
    end
  end

  def check_hungry_status
    if @phenotype.satiety <= HUNGRY_BORDER
      log "Want to eat (#{@phenotype.satiety})" unless @to_find_food  #talk about food only at first time
      @to_find_food = true
    else
      @to_find_food = false
    end
  end

  def check_reproduction_state
    if @genotype.reproductionability >= @phenotype.age && !@to_reproduct
      @to_reproduct = true if happens_with_probability? AGE_MUTATION_PROBABILITY
    end
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

end
