require_relative 'color_gene.rb'

class Genotype
  # Constant structure, generating at reproduction process

  attr_reader :survival_gene, :color_gene, :size_gene,
              :strength_gene, :sight_gene, :reproduction_gene

  def initialize(color_gene = ColorGene.default(DEFAULT_COLOR_GENE), survival_gene = DEFAULT_SURVIVAL_GENE,
                 size_gene = DEFAULT_SIZE_GENE, strength_gene = DEFAULT_STRENGTH_GENE,
                 sight_gene = DEFAULT_SIGHT_GENE, reproduction_gene = DEFAULT_REPRODUCTION_GENE)
    @color_gene = color_gene
    @survival_gene = survival_gene
    @size_gene = size_gene
    @strength_gene = strength_gene
    @sight_gene = sight_gene
    @reproduction_gene = reproduction_gene
  end

  def to_s
    #"#{@survival_gene.round 3}, #{@size_gene.round 3}, #{@strength_gene.round 3}"
    'Genotype'
  end

  def set(field, val)
    command = "@#{field} = #{val}"
    eval(command)
  end

  def self.default
    Genotype.new
  end

end