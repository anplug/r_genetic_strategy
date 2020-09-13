# frozen_string_literal: true

class Size
  attr_reader :w, :h

  def initialize(w, h)
    @w = w
    @h = h
  end

  def self.world
    @world ||= Size.new(S.window_width, S.window_height)
  end
end
