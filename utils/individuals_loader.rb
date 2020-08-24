require 'rexml/document'
require_relative 'argv_processor.rb'

class IndividualsLoader
  include REXML
  include Util

  extend ArgvProcessor

  DEFAULT_FILE_NAME = 'data/individuals.xml'

  def self.load
    file_name = get_parameter_value('individualsFile') || DEFAULT_FILE_NAME

    document = Document.new(File.new(file_name))

    document.root.elements.map { |individual| parse_individual(individual) }
  end

  def self.parse_individual(individual_elem)
    individual_elem.elements.each { |element| parse_element(element) }
    {
      position: @position,
      genotype: @genotype,
      phenotype: @phenotype
    }.tap do
      clear_temp
    end
  end

  def self.parse_element(element)
    name = element.attributes['name']
    if    name == 'position'  then @position  = parse_position(element.text)
    elsif name == 'Genotype'  then @genotype  = parse_genotype(element)
    elsif name == 'Phenotype' then @phenotype = parse_phenotype(element)
    end
  end

  def self.parse_position(position_elem)
    x, y = position_elem.split
    Position.new x.to_f, y.to_f
  end

  def self.parse_genotype(genotype_elem)
    genotype = Genotype.new
    genotype_elem.each do |var|
      if var.class != REXML::Text
        genotype.set(var.attributes['name'], var.text)
      end
    end
    genotype
  end

  def self.parse_phenotype(phenotype_elem)
    phenotype = Phenotype.new @genotype
    phenotype_elem.each do |var|
      if var.class != REXML::Text
        phenotype.set(var.attributes['name'], var.text.to_f)
      end
    end
    phenotype
  end

  def self.clear_temp
    @position = nil
    @genotype = nil
    @phenotype = nil
  end
end
