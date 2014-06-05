require_relative 'position.rb'

class GameObject

  attr_reader :sprite, :position

  def initialize(window, world_size, position, palette_path)
		@empty_image = Gosu::Image.new(window, palette_path, false)
    @world_size = world_size
    @position = position
  end

  def draw
    sprite.draw_rot(position.x, position.y, 1, 0.0)
  end

  def log(message)
    puts "#{self} #{message}"
  end

  def range(obj)
    @position.range obj.position
  end

end
