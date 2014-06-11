require_relative 'util.rb'

class ColorGene
  include Util

  @available_colors = [:red, :green, :blue]

  def initialize(color1, color2=color1)
    color1 = symbolic_representation color1 unless color1.instance_of? Symbol
    color2 = symbolic_representation color2 unless color2.instance_of? Symbol
    @colors = [color1, color2]
  end

  def generate_real_color
    if contains?(:red, :red) || contains?(:red, :blue)
      :red
    elsif contains?(:red, :green)
      happens_with_probability?(75) ? :red : :green
    elsif contains?(:green, :blue)
      happens_with_probability?(75) ? :green : :blue
    elsif contains?(:green, :green)
      :green
    else
      :blue
    end
  end

  def self.default(color)
    sym_color = symbolic_representation color
    self.new sym_color
  end

  def self.symbolic_representation(color_string)
    result = @available_colors.find {|available_color| available_color.to_s == color_string }
    raise ArgumentError, 'Unavailable color' unless result
    result
  end

  def contains?(color1, color2)
    (@colors[0] == color1 && @colors[1] == color2) || (@colors[1] == color1 && @colors[0] == color2)
  end

end