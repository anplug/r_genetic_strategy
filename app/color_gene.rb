# frozen_string_literal: true

class ColorGene
  attr_reader :colors

  AVAILABLE_COLORS = %i[red green blue].freeze

  def initialize(color1, color2 = color1)
    color1 = symbolic_representation(color1) unless color1.instance_of?(Symbol)
    color2 = symbolic_representation(color2) unless color2.instance_of?(Symbol)
    @colors = [color1, color2]
  end

  def to_s
    "#{@colors[0]}-#{@colors[1]}"
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def generate_real_color
    if contains?(:red, :red) || contains?(:red, :blue)
      :red
    elsif contains?(:red, :green)
      Rand.happens_with_probability?(75) ? :red : :green
    elsif contains?(:green, :blue)
      Rand.happens_with_probability?(75) ? :green : :blue
    elsif contains?(:green, :green)
      :green
    else
      :blue
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def contains?(color1, color2)
    (@colors[0] == color1 && @colors[1] == color2) || (@colors[1] == color1 && @colors[0] == color2)
  end

  def self.map_to_gosu(color)
    case color
    when :red then Gosu::Color.argb(0xffff0000)
    when :green then Gosu::Color.argb(0xff00ff00)
    when :blue then Gosu::Color.argb(0xff0000ff)
    end
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
    result = AVAILABLE_COLORS.find { |available_color| available_color.to_s == color_string }
    raise ArgumentError, 'Unavailable color' unless result

    result
  end

  def self.cross(gene1, gene2)
    ColorGene.new(gene1.colors.sample, gene2.colors.sample)
  end
end
