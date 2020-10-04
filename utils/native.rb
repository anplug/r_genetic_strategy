require 'inline'

class Inlined
  inline do |builder|
    builder.include('<math.h>')
    builder.c '
      double range(short int p1_x, short int p1_y, short int p2_x, short int p2_y) {
        return sqrt(pow(p1_x - p2_x, 2) + pow(p1_y - p2_y, 2));
      }'

    builder.c '
      int move(short int px, short int py, short int tx, short int ty, double speed) {
        int16_t x_ratio, y_ratio;
        int32_t result;
        float shift;

        x_ratio = (ty - py == 0) ? 1 : (tx - px) / abs(ty - py);
        y_ratio = (tx - px == 0) ? 1 : (ty - py) / abs(tx - px);

        shift = (abs(x_ratio) > abs(y_ratio)) ? abs(x_ratio) : abs(y_ratio);
        x_ratio /= shift;
        y_ratio /= shift;

        result = px + x_ratio * speed;
        result <<= 16;
        return result | (int16_t)(py + y_ratio * speed);
      }
    '
  end
end

Native = Inlined.new
