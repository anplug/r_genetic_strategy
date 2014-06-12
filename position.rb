require_relative 'size.rb'

class Position
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end
  
  def to_s
    "{#{@x.round}:#{@y.round}}" # А этот эксепшен совсем не был в моих планах. Могу только надееться что на защите такое не произойдёт
  end

  def range(pos)
    (((x - pos.x).abs ** 2) + ((y - pos.y).abs ** 2) ** 0.5)
  end

  def move(target, speed)
    target = get_real_position target
    x_ratio = if (target.y - @y) == 0 then 1
			        else                         (target.x - @x) / (target.y - @y).abs
			        end
		y_ratio = if (target.x - @x) == 0 then 1
			        else                         (target.y - @y) / (target.x - @x).abs
			        end
    if x_ratio.abs > y_ratio.abs
      x_ratio /= x_ratio.abs
      y_ratio /= x_ratio.abs
    else
      x_ratio /= y_ratio.abs
      y_ratio /= y_ratio.abs
    end
    @x += x_ratio * speed
    @y += y_ratio * speed
  end

  def ==(pos)
    pos = get_real_position pos
    (pos.x - @x).abs <= 1.0 && (pos.y - @y).abs <= 1.0
  end

  def get_real_position pos
    if pos.instance_of? Position
      pos
    else
      pos.position
    end
  end

  def self.inject_size(size)
    @size = size
  end

  def self.random
    Position.new(Random.rand(@size.w), Random.rand(@size.h))
  end


end