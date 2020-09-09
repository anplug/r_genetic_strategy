# frozen_string_literal: true

require_relative 'color_gene.rb'

class Genotype
  attr_reader :survival_gene, :color_gene, :size_gene,
              :strength_gene, :sight_gene, :reproduction_gene

  def initialize(color_gene = ColorGene.init(S.default_color_gene),
                 survival_gene = S.default_survival_gene,
                 size_gene = S.default_size_gene,
                 strength_gene = S.default_strength_gene,
                 sight_gene = S.default_sight_gene,
                 reproduction_gene = S.default_reproduction_gene)
    @color_gene = color_gene
    @survival_gene = survival_gene
    @size_gene = size_gene
    @strength_gene = strength_gene
    @sight_gene = sight_gene
    @reproduction_gene = reproduction_gene
  end

  def to_s
    # "#{@survival_gene.round 3}, #{@size_gene.round 3}, #{@strength_gene.round 3}"
    'Genotype'
  end

  def info
    <<-DOC
        strength_gene     = #{@strength_gene.round 3}
        sight_gene        = #{@sight_gene.round 3}
        survival_gene     = #{@survival_gene.round 3}
        reproduction_gene = #{@reproduction_gene.round 3}
        size_gene         = #{@size_gene.round 3}
        color             = #{@color_gene}
    DOC
  end

  def set(field, val)
    if field == 'color_gene'
      @color_gene = ColorGene.init val
    else
      command = "@#{field} = #{val}"
      eval(command)
    end
  end

  def self.genotype_crossing(genotype1, genotype2)
    cross mutate_genotype(genotype1), mutate_genotype(genotype2)
  end

  def self.mutate_genotype(genotype)
    mutated_survival_gene = mutate_gene genotype.survival_gene
    mutated_size_gene = mutate_gene genotype.size_gene
    mutated_strength_gene = mutate_gene genotype.strength_gene
    mutated_sight_gene = mutate_gene genotype.sight_gene
    mutated_reproduction_gene = mutate_gene genotype.reproduction_gene

    Genotype.new genotype.color_gene, mutated_survival_gene, mutated_size_gene,
                 mutated_strength_gene, mutated_sight_gene, mutated_reproduction_gene
  end

  def self.cross(genotype1, genotype2)
    color_gene = ColorGene.cross genotype1.color_gene, genotype2.color_gene
    size_gene = cross_gene genotype1.size_gene, genotype2.size_gene
    strength_gene = cross_gene genotype1.strength_gene, genotype2.strength_gene
    sight_gene = cross_gene genotype1.sight_gene, genotype2.sight_gene
    survival_gene = cross_gene genotype1.survival_gene, genotype2.survival_gene
    reproduction_gene = cross_gene genotype1.survival_gene, genotype2.reproduction_gene

    Genotype.new color_gene, survival_gene, size_gene,
                 strength_gene, sight_gene, reproduction_gene
  end

  def self.mutate_gene(gene)
    rand_in_range(gene / 2, gene + gene / 2)
  end

  def self.cross_gene(gene1, gene2)
    gene1, gene2 = gene2, gene1 if gene2 > gene1
    rand_in_range(gene1, gene2)
  end

  def self.rand_in_range(min, max)
    rand * (max - min) + min
  end
end
