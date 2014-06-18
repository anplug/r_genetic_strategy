require_relative 'util.rb'

class ColorGene
  include Util

  attr_reader :colors

  @available_colors = [:red, :green, :blue]

  def to_s
    "#{@colors[0].to_s}-#{@colors[1].to_s}"
  end

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

  def contains?(color1, color2)
    (@colors[0] == color1 && @colors[1] == color2) || (@colors[1] == color1 && @colors[0] == color2)
  end


  def self.init(color_string)
    colors = color_string.split
    if colors.size >= 2
      new symbolic_representation(colors[0]), symbolic_representation(colors[1])
    else
      new symbolic_representation(colors.first)
    end
  end

  def self.symbolic_representation(color_string)
    result = @available_colors.find {|available_color| available_color.to_s == color_string }
    raise ArgumentError, 'Unavailable color' unless result
    result
  end

  def self.cross(gene1, gene2)
    ColorGene.new gene1.colors.sample, gene2.colors.sample
  end

end