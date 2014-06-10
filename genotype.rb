class Genotype
  # Constant structure, generating at reproduction process

  attr_reader :survivability, :colorability, :sizeability, :strengthability,
              :viewability, :reproductionability

  def initialize(survivability = DEFAULT_SURVIVABILITY, colorability = DEFAULT_COLORABILITY,
                 sizeability = DEFAULT_SIZEABILITY, strenghtability = DEFAULT_STRENGTHABILITY,
                 viewability = DEFAULT_VIEWABILITY, reproductionability = DEFAULT_REPRODUCTIONABILITY)
    @survivability = survivability
    @colorability = colorability
    @strengthability = strenghtability
    @sizeability = sizeability
    @viewability = viewability
    @reproductionability = reproductionability
  end

  def to_s
    #"#{@survivability.round 3}, #{@sizeability.round 3}, #{@strengthability.round 3}"
    'genotype'
  end

  def set(field, val)
    command = "@#{field} = #{val}"
    eval(command)
  end

end