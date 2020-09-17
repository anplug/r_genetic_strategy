# frozen_string_literal: true

class Argv
  def self.get_parameter_value(parameter)
    ARGV.each_with_index do |elem, index|
      return ARGV[index + 1] if elem == parameter && index < ARGV.size
    end
    nil
  end

  def self.parameter_present?(parameters)
    parameters = [parameters] unless parameters.is_a?(Array)
    parameters.any? { |p| ARGV.include?(p) }
  end
end
