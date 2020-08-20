#!/usr/bin/env ruby

require 'gosu'
require 'pry'
require 'rmagick'

require_relative 'app/world.rb'
require_relative 'app/size.rb'
require_relative 'app/util.rb'

require_relative 'utils/argv_processor.rb'
require_relative 'utils/data_loader.rb'
require_relative 'utils/individuals_loader.rb'

class GenWindow < Gosu::Window
  def initialize(world, headless_mode)
    @world = world
    @headless_mode = headless_mode
    update_interval = headless_mode ? 0 : (1000 / FPS)
    super(WINDOW_WIDTH, WINDOW_HEIGHT, false, update_interval)
    self.caption = WINDOW_CAPTION
  end

  private

  def update
    @world.update
  end

  def draw
    unless @headless_mode
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

class App
  extend ArgvProcessor

  class << self
    def run
      File.delete("statistics") rescue false

      DataLoader.load

      headless_mode = parameter_present?('headless')
      load_individuals = parameter_present?('loadIndividuals')

      binding.pry
      world = World.new(Size.new(WINDOW_WIDTH, WINDOW_HEIGHT), load_individuals)
      GenWindow.new(world, headless_mode).show
    end
  end
end

App.run
