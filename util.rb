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

  def parameter_present?(parameter)
    ARGV.include? parameter
  end

  def get_parameter_value(parameter)
    ARGV.each_with_index do |elem, index|
      if elem == parameter && index < ARGV.size
        return ARGV[index + 1]
      end
    end
    nil
  end

end