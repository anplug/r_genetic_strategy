# frozen_string_literal: true

class GameObject
  attr_reader :sprite, :position

  RED = Gosu::Color.argb(0xffff0000)

  def initialize(position)
    @position = position
  end

  def draw
    # Drawing center
    $env.draw_rect(position.x, position.y, 1, 1, RED, 0, :default)
  end

  def log(message)
    # puts "#{self} #{message}"
  end

  def range(obj)
    @position.range(obj.position)
  end
end
