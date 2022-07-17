#!/usr/bin/env ruby
# frozen_string_literal: true

require 'gosu'

require_relative 'utils/argv'
require_relative 'utils/size'
require_relative 'utils/position'
require_relative 'utils/settings'
require_relative 'utils/individuals_loader'
require_relative 'utils/rand'

require_relative 'app/world'
require_relative 'app/game_object'
require_relative 'app/individual'
require_relative 'app/genotype'
require_relative 'app/color_gene'
require_relative 'app/phenotype'
require_relative 'app/food'
require_relative 'app/dying_from_starving'

if Argv.parameter_present?(%w[d debug])
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
          update_interval:)
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
    loop do
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
