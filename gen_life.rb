require 'gosu'
require_relative 'data_loader.rb'
require_relative 'world.rb'
require_relative 'size.rb'

class GenWindow < Gosu::Window

	def initialize
		super WINDOW_WIDTH, WINDOW_HEIGHT, false, 1000 / FPS
		self.caption = WINDOW_CAPTION
    @world  = World.new(self, Size.new(WINDOW_WIDTH, WINDOW_HEIGHT))
	end

	def update
    @world.update
	end

	def draw
    draw_background
    @world.draw
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

#need to install this via gem OCRA

input_file_name = 'data.xml'
data_loader = DataLoader.new input_file_name
data_loader.load
window = GenWindow.new
window.show