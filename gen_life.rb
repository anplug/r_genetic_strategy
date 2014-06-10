require 'gosu'
require_relative 'data_loader.rb'
require_relative 'world.rb'
require_relative 'size.rb'
require_relative 'util.rb'
require_relative 'individuals_loader.rb'

include Util

class GenWindow < Gosu::Window

  def initialize(interactive_mode, to_load_individuals)
    @interactive_mode = interactive_mode
    update_interval = interactive_mode ? (1000 / FPS) : 0
    super WINDOW_WIDTH, WINDOW_HEIGHT, false, update_interval
    self.caption = WINDOW_CAPTION
    @world  = World.new(self, Size.new(WINDOW_WIDTH, WINDOW_HEIGHT), to_load_individuals)
  end

  def update
    @world.update
  end

  def draw
    if @interactive_mode
      draw_background
      @world.draw
    end
  end

  def draw_background
    return unless BACKGROUND
    color = Gosu::Color.argb(BACKGROUND_COLOR)
    draw_quad(
        0,     		    0,      		   color,
        WINDOW_WIDTH, 0,      		   color,
        0,     		    WINDOW_HEIGHT, color,
        WINDOW_WIDTH, WINDOW_HEIGHT, color,
        0)
  end

end

input_file_name = get_parameter_value('inputFile') || 'data.xml'
individuals_file = get_parameter_value('individualsFile') || 'individuals.xml'
interactive_mode = !parameter_present?('nonInteractive')
to_load_individuals = parameter_present?('loadIndividuals')
DataLoader.load input_file_name
IndividualsLoader.init(individuals_file)
window = GenWindow.new interactive_mode, to_load_individuals
window.show