#!/usr/bin/env ruby
# frozen_string_literal: true

require 'gosu'
require 'rmagick'

require_relative 'utils/argv.rb'
require_relative 'utils/size.rb'
require_relative 'utils/position.rb'
require_relative 'utils/settings.rb'
require_relative 'utils/individuals_loader.rb'
require_relative 'utils/rand.rb'

require_relative 'app/world.rb'
require_relative 'app/game_object.rb'
require_relative 'app/individual.rb'
require_relative 'app/genotype.rb'
require_relative 'app/color_gene.rb'
require_relative 'app/phenotype.rb'
require_relative 'app/food.rb'
require_relative 'app/dying_from_starving.rb'

if Argv.parameter_present?(['d', 'debug'])
  require 'pry'
  require 'benchmark'
end

class GenWindow < Gosu::Window
  def initialize(world)
    @world = world
    update_interval = 1000 / S.fps
    super(S.window_width, S.window_height,
          fullscreen: false,
          resizable: false,
          update_interval: update_interval)
    self.caption = S.window_caption
  end

  def perform
    show
  end

  private

  def update
    @world.update
  end

  def draw
    @world.draw
  end
end

class HeadlessProcess
  def initialize(world)
    @world = world
  end

  def perform
    while true
      @world.update
    end
  end
end

class App
  class << self
    def run
      begin
        File.delete('statistics')
      rescue StandardError
        false
      end
      Settings.load

      headless_mode = Argv.parameter_present?('headless')
      load_individuals = Argv.parameter_present?('loadIndividuals')

      world = World.new(load_individuals)
      $env = (headless_mode ? HeadlessProcess : GenWindow).new(world)
      $env.perform
    end
  end
end

App.run
