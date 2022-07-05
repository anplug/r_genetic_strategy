# frozen_string_literal: true

class Individual < GameObject
  attr_reader :id, :genotype, :phenotype, :reproduction_pair, :is_dead

  attr_accessor :near_individuals, :near_food

  def fitness_function
    result = @genotype.strength_gene     * 0.35 +
             @genotype.sight_gene        * 0.30 +
             @genotype.survival_gene     * 0.20 +
             @genotype.reproduction_gene * 0.10 +
             @genotype.size_gene         * 0.05
    result / 5
  end

  protected def initialize(id:,
                           position:,
                           genotype:,
                           phenotype: nil)

    position = position || Rand.position
    genotype = genotype || Genotype.new

    super(position)
    @id = id
    @genotype = genotype
    @phenotype = phenotype || Phenotype.new(genotype)

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
  end

  def update(_world)
    if !in_reproduction?
      make_decision
      process_view
      @is_moving = moving
    else
      @is_moving = false
    end
    @phenotype.update(@genotype, @is_moving)
  rescue DyingFromStarving
    @is_dead = true
  end

  def draw
    size = @phenotype.absolute_size
    color = @phenotype.color_tech

    $env.draw_quad(
      position.x - size, position.y       , color,
      position.x,        position.y + size, color,
      position.x + size, position.y       , color,
      position.x,        position.y - size, color,
      0, :default
    )

    inner_size = size * 0.7

    $env.draw_quad(
      position.x - inner_size, position.y - inner_size, color,
      position.x + inner_size, position.y - inner_size, color,
      position.x - inner_size, position.y + inner_size, color,
      position.x + inner_size, position.y + inner_size, color,
      0, :default
    )

    super
  end

  def to_s
    "<#{@id} at #{@position}>:#{@phenotype.satiety}"
  end

  def get_reproduction_pair
    return nil if @reproduction_pair.empty?

    temp = @reproduction_pair
    @reproduction_pair = []
    temp
  end

  def in_view_scope?(obj)
    if obj.instance_of?(Individual)
      (@position.range(obj.position) - obj.phenotype.absolute_size / 2) <= @phenotype.view_scope
    else
      @position.range(obj.position) <= @phenotype.view_scope
    end
  end

  private def need_to_update_sprite?
    if @need_to_update_sprite
      @need_to_update_sprite = false
      return true
    end
    false
  end

  private def make_decision
    set_hungry_status
    set_reproduction_state
  end

  private def set_hungry_status
    if @phenotype.satiety <= S.hungry_border
      log("Want to eat (#{@phenotype.satiety})") unless @want_to_eat # talk about food only at first time
      @want_to_eat = true
    else
      @want_to_eat = false
    end
  end

  private def set_reproduction_state
    if @phenotype.age > @genotype.reproduction_gene
      if @just_reproducted
        @iterations_after_reproduction += 1
        if @iterations_after_reproduction == S.iterations_after_reproducting
          @just_reproducted = false
          @iterations_after_reproduction = 0
        end
      elsif !@want_to_reproduct
        @want_to_reproduct = true if Rand.happens_with_probability?(S.age_mutation_probability)
        log "Want to reproduct (#{@phenotype.age})" if @want_to_reproduct
      end
    end
  end

  private def process_view
    return false if target_is_object? || !have_business?

    food = most_appropriate_food if @want_to_eat
    pair = most_appropriate_pair if @want_to_reproduct
    return false if !food && !pair

    set_target food, pair
  end

  private def set_target(food, pair)
    priority = desire_priority
    if priority == Food || priority.nil?
      @target = food || pair
    elsif priority == Individual
      @target = pair || food
    else
      raise ArgumentError, 'Unsupported target type'
    end
    log "My target is [#{@target}]"
  end

  private def desire_priority
    if @phenotype.satiety < S.starving_border
      Food
    elsif @want_to_reproduct
      Individual
    end
  end

  private def moving
    return false unless have_business?

    if target_reached?
      make_action
      return false
    end
    @target = generate_random_target if @target.nil?

    @position.move(@target, @phenotype.speed)
    true
  end

  private def generate_random_target
    target = Rand.position
    # puts "Generate target = #{@position} -> #{target}, searching..."
    target
  end

  private def have_business?
    @want_to_eat || @want_to_reproduct
  end

  private def target_reached?
    @position == @target if @target
  end

  private def make_action
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

  private def reproduction_stage
    log 'Here, reproduction stage!'
    if @passive
      log "Have proposal from #{@target}"
    else
      log 'Im active!'
      @active = true
      answer = @target.reproduction_proposal(self)
      if answer
        @pair = @target
        @in_reproduction = true
      else
        log "Reproduction rejected from #{@target}"
        @active = false
      end
    end
  end

  protected def reproduction_proposal(pair)
    if suitable_individual(pair)
      log 'Im passive!'
      @passive = true
      @pair = pair
      @in_reproduction = true
      true
    else
      false
    end
  end

  private def eat_transaction
    owner = @target.owner
    if owner == self || owner.nil? || !owner.stronger?(@phenotype.strength)
      log "Eating #{@target}" #: #{owner} is weakly" if owner.class == Individual
      feeding_operation if @target.try_to_eat self
    else
      # log "Can't eat #{@target} : #{owner} is stronger"
    end
  end

  private def feeding_operation
    old_satiety = @phenotype.satiety
    @phenotype.satiety += S.food_per_point
    log "I got food #{old_satiety} --> #{@phenotype.satiety}"
  end

  private def most_appropriate_food
    # puts "#{self} see -> #{@near_food}" if @near_food
    @near_food ? closest_object(@near_food) : nil
  end

  private def most_appropriate_pair
    # puts "#{self} see -> #{@near_individuals}" if @near_individuals
    @near_individuals ? closest_object(@near_individuals) : nil # most atractive
  end

  private def closest_object(objects)
    if objects.count == 1
      closest_obj = objects.first
    else
      obj_range_hash = create_obj_range_hash(objects)
      closest_obj = obj_range_hash.max_by { |_k, v| v }.first
    end
    log "Closest #{closest_obj.class} is #{closest_obj}"
    closest_obj
  end

  private def create_obj_range_hash(objects_arr)
    objects_arr.each_with_object({}) { |elem, result| result[elem] = range(elem) }
  end

  private def target_is_object?
    @target && !@target.instance_of?(Position)
  end

  protected def stronger?(strength)
    @phenotype.strength > strength
  end

  private def suitable_individual(_potential_pair)
    if @want_to_reproduct
      true
    else
      false
    end
  end

  private def in_reproduction?
    return false unless @in_reproduction

    @iterations_in_reproduction += 1
    if @iterations_in_reproduction == S.reproduction_phase_time
      @reproduction_pair = [self, @pair] if @active # real pair generating only at end of reproduction
      @pair = nil
      @want_to_reproduct = false
      @just_reproducted = true
      @in_reproduction = false
      @iterations_in_reproduction = 0
      @active = false
      @passive = false
      log 'Finished reproduction'
    end
    true
  end
end
