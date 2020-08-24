require_relative 'genotype.rb'
require_relative 'dying_from_starving.rb'

class Phenotype

  attr_reader :color, :attractiveness, :age, :strength, :size, :speed, :view_scope
  attr_accessor :satiety

  def initialize(genotype, attractiveness = S.default_attractiveness,
                 age = S.default_age,
                 strength = S.default_strength,
                 size = S.default_size,
                 speed = S.default_speed,
                 view_scope = S.default_view_scope)
    @color = genotype.color_gene.generate_real_color
    @age = age
    @strength = strength
    @size = size
    @speed = speed
    @view_scope = view_scope
    @satiety = S.initial_satiety
    @attractiveness = attractiveness

    @update_sprite_flag = false
  end

  def update_sprite?
    @update_sprite_flag
  end

  def to_s
    "#{@attractiveness.round 3}, #{@age.round 3}, #{@strength.round 3}, #{@size.round 3}, #{@speed.round 3}"
  end

  def absolute_size
    @size * S.size_coefficient
  end

  def maximum_size?
    absolute_size >= S.maximum_size
  end

  def positive_feed_factor
    negative_feed_factor.abs
  end

  def negative_feed_factor
    (@satiety**3)/1.0
  end

  def update(genotype, is_moving)
    update_age
    update_strength genotype
    update_size genotype
    update_speed
    update_view_scope genotype
    update_satiety is_moving
  end

  # Parameter updaters

  def update_age
    @age += S.age_incr
  end

  def update_strength(genotype)
    @strength += genotype.strength_gene * S.strength_incr * negative_feed_factor
  end

  def update_size(genotype)
    # TODO : individual's size doesn't have to have restriction
    unless maximum_size?
      prev_size = absolute_size
      feed_factor = positive_feed_factor
      val = genotype.size_gene * S.size_incr * feed_factor
      @size += val
      @update_sprite_flag = absolute_size.to_i - prev_size.to_i != 0
    end
  end

  def update_speed
    size_strength_coef = @strength / @size
    size_strength_coef *= -1 if size_strength_coef <= S.strength_to_size_max_coef
    @speed += S.speed_incr * size_strength_coef
  end

  def update_view_scope(genotype)
    @view_scope -= S.view_scope_incr * (1 / genotype.sight_gene)
  end

  def update_satiety(is_moving)
    if @satiety <= 0
      @satiety = 0
      raise DyingFromStarving
    end
    @satiety -= (S.satiety_incr * @size * positive_feed_factor + (is_moving ? S.satiety_incr : 0))
  end

  def set(field, val)
    command = "@#{field} = #{val}"
    eval(command)
  end

  def self.default(genotype)
    Phenotype.new genotype
  end
end
