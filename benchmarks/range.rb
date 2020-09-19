# $ ruby test.rb
# Positions generated
# Rehearsal -----------------------------------------------------
# original           10.014700   0.019950  10.034650 ( 10.072520)
# original_inlined   10.374534   0.003299  10.377833 ( 10.416894)
# optimized           7.299961   0.000014   7.299975 (  7.327705)
# optimized_inlined   8.293402   0.023166   8.316568 (  8.347993)
# c                   5.719928   0.000000   5.719928 (  5.741654)
# ------------------------------------------- total: 41.748954sec
#
#                         user     system      total        real
# original            9.975145   0.023278   9.998423 ( 10.036138)
# original_inlined   10.454186   0.003315  10.457501 ( 10.496953)
# optimized           7.261186   0.003280   7.264466 (  7.292050)
# optimized_inlined   8.261842   0.000060   8.261902 (  8.293217)
# c                   5.661242   0.000036   5.661278 (  5.683370)

size = Size.new(480, 640)
iterations = 100_000
positions = (1..(iterations * 2)).map { Rand.position(size) }

puts 'Positions generated'

sum1 = 0
sum2 = 0
sum3 = 0
sum4 = 0
sum5 = 0

def range(pos1, pos2)
  ((pos1.x - pos2.x).abs**2 + (pos1.y - pos2.y).abs**2)**0.5
end

def irange(p1_x, p2_x, p1_y, p2_y)
  ((p1_x - p2_x).abs**2 + (p1_y - p2_y).abs**2)**0.5
end

def orange(pos1, pos2)
  a = pos1.x - pos2.x
  b = pos1.y - pos2.y
  (a * a + b * b)**0.5
end

def oirange(p1_x, p2_x, p1_y, p2_y)
  a = p1_x - p2_x
  b = p1_y - p2_y
  (a * a + b * b)**0.5
end

Benchmark.bmbm(8) do |x|
  x.report('original') do
    iterations.times do |i|
      sum1 += range(positions[i], positions[i + 1])
    end
  end

  x.report('original_inlined') do
    iterations.times do |i|
      sum2 += irange(positions[i].x, positions[i + 1].x, positions[i].y, positions[i + 1].y)
    end
  end

  x.report('optimized') do
    iterations.times do |i|
      sum3 += orange(positions[i], positions[i + 1])
    end
  end

  x.report('optimized_inlined') do
    iterations.times do |i|
      sum4 += oirange(positions[i].x, positions[i + 1].x, positions[i].y, positions[i + 1].y)
    end
  end

  x.report('c') do
    iterations.times do |i|
      sum5 += Native.range(positions[i].x, positions[i].y, positions[i + 1].x, positions[i + 1].y)
    end
  end
end

puts sum1
puts sum2
puts sum3
puts sum4
puts sum5
