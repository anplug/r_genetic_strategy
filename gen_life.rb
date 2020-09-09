#!/usr/bin/env ruby
# frozen_string_literal: true

require 'gosu'
require 'pry'
require 'rmagick'

require_relative 'app/world.rb'
require_relative 'app/size.rb'
require_relative 'app/util.rb'

require_relative 'utils/argv_processor.rb'
require_relative 'utils/settings.rb'
require_relative 'utils/individuals_loader.rb'

class GenWindow < Gosu::Window
  def initialize(world, headless_mode)
    @world = world
    @headless_mode = headless_mode
    update_interval = headless_mode ? 0 : (1000 / S.fps)
    super(S.window_width, S.window_height, false, update_interval)
    self.caption = S.window_caption
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
    return unless S.background

    color = Gosu::Color.argb(S.background_color)
    draw_quad(
      0, 0, color,
      S.window_width, 0, color,
      0, S.window_height, color,
      S.window_width, S.window_height, color,
      0
    )
  end
end

class App
  extend ArgvProcessor

  class << self
    def run
      begin
        File.delete('statistics')
      rescue StandardError
        false
      end
      Settings.load

      headless_mode = parameter_present?('headless')
      load_individuals = parameter_present?('loadIndividuals')

      world = World.new(Size.new(S.window_width, S.window_height), load_individuals)
      GenWindow.new(world, headless_mode).show
    end
  end
end

App.run
