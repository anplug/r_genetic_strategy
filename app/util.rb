module Util
  def happens_with_probability?(prob)
    raise ArgumentError, 'Negative probability' if prob <= 0
    return true if prob >= 100
    prob /= 100.0
    srand
    r_value = rand
    if r_value < prob
      true
    else
      false
    end
  end

  def rand_in_range(min, max)
    rand * (max - min) + min
  end
end
