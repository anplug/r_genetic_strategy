# frozen_string_literal: true

require_relative 'position.rb'

class GameObject
  attr_reader :sprite, :position

  def initialize(position)
    @position = position
  end

  def draw
    Gosu::Image.new(sprite).draw(position.x, position.y, 1)
  end

  def log(message)
    # puts "#{self} #{message}"
  end

  def range(obj)
    @position.range obj.position
  end

  protected def update_sprite(image_size)
    @sprite = Magick::Image.new(image_size, image_size)
    sprite.matte_reset!
  end
end
