module ArgvProcessor
  def get_parameter_value(parameter)
    ARGV.each_with_index do |elem, index|
      if elem == parameter && index < ARGV.size
        return ARGV[index + 1]
      end
    end
    nil
  end

  def parameter_present?(parameter)
    ARGV.include?(parameter)
  end
end
