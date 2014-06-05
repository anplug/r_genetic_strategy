module Util

  def happens_with_probability?(prob)
    return false if prob <= 0
    prob = 100 if prob > 100
    pr = prob / 100.0
    #randomizer = Random.new_seed
    srand
    #if pr < randomizer.rand
    if pr < rand
      true
    else
      false
    end
  end

end