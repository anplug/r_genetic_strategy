class Food < GameObject

  def initialize(window, world_size, position, saturation = DEFAULT_SATURATION)
    super(window, world_size, position, PALETTE_PATH)
    @saturation = saturation >= IMAGE_SIZE**2 ? IMAGE_SIZE**2 : saturation
    @eaten = false
    update_sprite
  end

  def to_s
    "<Food at #{@position}>"
  end

  def empty?
    return true if @saturation == 0
    false
  end

  def update
    if @eaten
      update_sprite
      @eaten = false
    end
  end

  def eat
    unless @saturation == 0
      @saturation -= 1
      @eaten = true
      return true
    end
    false
  end

  def update_sprite
    # draw sprite in two stages, draw full-length lines, than draw part of last line
    @sprite = @empty_image.clone
    full_lines = self.full_lines
    last_line_length = self.last_line_length
    full_lines.times do |index|
      @sprite.paint{
        line(0, index, IMAGE_SIZE - 1, index)
      }
    end
    if last_line_length != 0
      @sprite.paint{
        line(0, full_lines, last_line_length - 1, full_lines)
      }
    end
  end

  protected

  def full_lines
    @saturation / IMAGE_SIZE
  end

  def last_line_length
    @saturation % IMAGE_SIZE
  end

end