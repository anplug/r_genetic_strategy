# frozen_string_literal: true

module ArgvProcessor
  def get_parameter_value(parameter)
    ARGV.each_with_index do |elem, index|
      return ARGV[index + 1] if elem == parameter && index < ARGV.size
    end
    nil
  end

  def parameter_present?(parameter)
    ARGV.include?(parameter)
  end
end
