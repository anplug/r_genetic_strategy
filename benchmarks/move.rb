size = Size.new(480, 640)
iterations = 10000000
positions = (1..iterations).map { Rand.position(size) }
targets = (1..iterations).map { Rand.position(size) }
speeds = (1..iterations).map{ Rand.float_to(3) }

puts 'Data generated'

def move(position, target, speed)
  target = get_real_position(target)
  x_ratio = if (target.y - position.y).zero? then 1
            else (target.x - position.x) / (target.y - position.y).abs
            end
  y_ratio = if (target.x - position.x).zero? then 1
            else (target.y - position.y) / (target.x - position.x).abs
            end

  if x_ratio.abs > y_ratio.abs
    x_ratio /= x_ratio.abs
    y_ratio /= x_ratio.abs
  else
    x_ratio /= y_ratio.abs
    y_ratio /= y_ratio.abs
  end
  x = position.x + x_ratio * speed
  y = position.y + y_ratio * speed
  [x.floor, y.floor]
end

def omove(position, target, speed)
  target = get_real_position(target)

  res = Native.move(position.x, position.y, target.x, target.y, speed)

  [res >> 16, res & 65535]
end

def o2move(position, target, speed)
  target = get_real_position(target)

  res = Native.omove(position.x, position.y, target.x, target.y, speed)

  [res >> 16, res & 65535]
end

def o3move(position, target, speed)
  target = get_real_position(target)

  res = Native.o2move(position.x, position.y, target.x, target.y, speed)

  [res >> 16, res & 65535]
end

def get_real_position(pos)
  pos.instance_of?(Position) ? pos : pos.position
end

Benchmark.bmbm(8) do |x|
  x.report('original') do
    iterations.times do |i|
      res1 = move(positions[i], targets[i], speeds[i])
    end
  end

  x.report('cmove') do
    iterations.times do |i|
      res2 = omove(positions[i], targets[i], speeds[i])
    end
  end

  x.report('omove') do
    iterations.times do |i|
      res3 = o2move(positions[i], targets[i], speeds[i])
    end
  end

  x.report('ternarless') do
    iterations.times do |i|
      res3 = o3move(positions[i], targets[i], speeds[i])
    end
  end
end
