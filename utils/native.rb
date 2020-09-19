require 'inline'

class Inlined
  inline do |builder|
    builder.include('<math.h>')
    builder.c '
      double range(short int p1_x, short int p1_y, short int p2_x, short int p2_y) {
        return sqrt(pow(p1_x - p2_x, 2) + pow(p1_y - p2_y, 2));
      }'
  end
end

Native = Inlined.new
