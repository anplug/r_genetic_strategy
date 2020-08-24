class Food < GameObject
  def initialize(position, saturation = S.default_saturation)
    super(position)
    @saturation = saturation >= S.image_size(:food)**2 ? S.image_size(:food)**2 : saturation
    @eaten = false
    @owner = nil
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

  def get_owner
    @owner
  end

  def try_to_eat(pretender)
    return false if @saturation == 0
    @owner = pretender
    eat
  end

  def eat
    @saturation -= 1
    @eaten = true
    true
  end

  def update_sprite
    super(S.image_size(:food))
    line = Magick::Draw.new
    full_lines = self.full_lines
    full_lines.times do |index|
      line.line(0, index, S.image_size(:food) - 1, index)
    end
    if last_line_length != 0
      line.line(0, full_lines, last_line_length - 1, full_lines)
    end
    line.draw(sprite) unless @eaten
  end

  protected

  def full_lines
    @saturation / S.image_size(:food)
  end

  def last_line_length
    @saturation % S.image_size(:food)
  end
end
