# frozen_string_literal: true

class Rand
  def self.happens_with_probability?(prob)
    raise ArgumentError, 'Negative probability' if prob <= 0
    return true if prob >= 100

    prob /= 100.0
    srand
    r_value = rand
    r_value < prob
  end

  def self.in_range(min, max)
    (rand * (max - min)) + min
  end

  def self.position(size = Size.world, padding: 0)
    Position.new(rand(size.w - (padding * 2)) + padding,
                 rand(size.h - (padding * 2)) + padding)
  end
end
