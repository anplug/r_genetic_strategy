# frozen_string_literal: true

require_relative 'native'

class Position
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_s
    "{#{@x.round}:#{@y.round}}"
  rescue StandardError
    puts @x, @y
  end

  def range(other)
    Native.range(x, other.x, y, other.y)
  end

  def move(target, speed) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    target = get_real_position(target)
    x_ratio = if (target.y - @y).zero? then 1
              else (target.x - @x) / (target.y - @y).abs
              end
    y_ratio = if (target.x - @x).zero? then 1
              else (target.y - @y) / (target.x - @x).abs
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

  def ==(other)
    other = get_real_position(other)
    (other.x - @x).abs <= 1.0 && (other.y - @y).abs <= 1.0
  end

  def get_real_position(other)
    if other.instance_of?(Position)
      other
    else
      other.position
    end
  end
end
