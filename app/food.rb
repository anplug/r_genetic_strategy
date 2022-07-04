# frozen_string_literal: true

class Food < GameObject
  def initialize(position, saturation = S.default_saturation)
    super(position)
    @saturation = saturation >= S.image_size(:food)**2 ? S.image_size(:food)**2 : saturation
    @eaten = false
    @owner = nil
    @color = Gosu::Color.argb(0xffffffff)
  end

  attr_reader :owner

  def to_s
    "<Food at #{@position}>"
  end

  def empty?
    return true if @saturation.zero?

    false
  end

  def update
    if @eaten
      # That's interesting
      @eaten = false
    end
  end

  def try_to_eat(pretender)
    return false if @saturation.zero?

    @owner = pretender
    eat
  end

  def draw
    size = @saturation

    $env.draw_quad(
      position.x,        position.y,        @color,
      position.x + size, position.y,        @color,
      position.x + size, position.y + size, @color,
      position.x,        position.y + size, @color,
      0, :default
    )
  end

  private def eat
    @saturation -= 1
    @eaten = true
    true
  end
end
