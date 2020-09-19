require 'inline'

class Inlined
  inline do |builder|
    builder.include('<math.h>')
    builder.include('<stdint.h>')
    builder.c '
      double range(short int p1_x, short int p1_y, short int p2_x, short int p2_y) {
        return sqrt(pow(p1_x - p2_x, 2) + pow(p1_y - p2_y, 2));
      }'

    builder.c '
      int move(short int px, short int py, short int tx, short int ty, double speed) {
        int16_t x_ratio, y_ratio;
        int32_t result;

        if (ty - py == 0) {
          x_ratio = 1;
        } else {
          x_ratio = (tx - px) / abs(ty - py);
        }

        if (tx - px == 0) {
          y_ratio = 1;
        } else {
          y_ratio = (ty - py) / abs(tx - px);
        }

        if (abs(x_ratio) > abs(y_ratio)) {
          x_ratio /= abs(x_ratio);
          y_ratio /= abs(x_ratio);
        } else {
          x_ratio /= abs(y_ratio);
          y_ratio /= abs(y_ratio);
        }

        result = px + x_ratio * speed;
        result <<= 16;
        result |= (int16_t)(py + y_ratio * speed);
        return result;
      }'

    builder.c '
      int omove(short int px, short int py, short int tx, short int ty, double speed) {
        int16_t x_ratio, y_ratio;
        int32_t result;

        x_ratio = (ty - py == 0) ? 1 : (tx - px) / abs(ty - py);
        y_ratio = (tx - px == 0) ? 1 : (ty - py) / abs(tx - px);

        x_ratio /= (abs(x_ratio) > abs(y_ratio)) ? abs(x_ratio) : abs(y_ratio);
        y_ratio /= (abs(x_ratio) > abs(y_ratio)) ? abs(x_ratio) : abs(y_ratio);

        result = px + x_ratio * speed;
        result <<= 16;
        result |= (int16_t)(py + y_ratio * speed);
        return result;
      }'

    builder.c '
      int o2move(short int px, short int py, short int tx, short int ty, double speed) {
        int16_t x_ratio, y_ratio;
        int32_t result;
        short int xy, yx;

        x_ratio = (ty - py == 0) ? 1 : (tx - px) / abs(ty - py);
        y_ratio = (tx - px == 0) ? 1 : (ty - py) / abs(tx - px);

        xy = abs(x_ratio) > abs(y_ratio);
        yx = abs(x_ratio) <= abs(y_ratio);
        x_ratio /= xy * abs(x_ratio) + yx * abs(y_ratio);
        y_ratio /= xy * abs(x_ratio) + yx * abs(y_ratio);

        result = px + x_ratio * speed;
        result <<= 16;
        result |= (int16_t)(py + y_ratio * speed);
        return result;
      }'
  end
end

Native = Inlined.new
