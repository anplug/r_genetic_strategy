# frozen_string_literal: true

class Food < GameObject
  def initialize(position, saturation = S.default_saturation)
    super(position)
    @saturation = saturation
    @eaten = false
    @owner = nil
    @color = Gosu::Color.argb(0xffffffff)
  end

  attr_reader :owner

  def self.default_size
    S.default_saturation / 2
  end

  def to_s
    "<Food at #{@position}>"
  end

  def empty?
    return true if @saturation.zero?

    false
  end

  # rubocop:disable Style/GuardClause
  # TODO: think about it
  def update
    if @eaten
      # That's interesting
      @eaten = false
    end
  end
  # rubocop:enable Style/GuardClause

  def try_to_eat(pretender)
    return false if @saturation.zero?

    @owner = pretender
    eat
  end

  def draw # rubocop:disable Metrics/AbcSize
    size = @saturation / 2

    $env.draw_quad(
      position.x - size, position.y - size, @color,
      position.x + size, position.y - size, @color,
      position.x - size, position.y + size, @color,
      position.x + size, position.y + size, @color,
      0, :default
    )

    super
  end

  private def eat
    @saturation -= 1
    @eaten = true
    true
  end
end
