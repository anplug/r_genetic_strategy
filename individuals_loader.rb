require 'rexml/document'

class IndividualsLoader
  include REXML

  def self.init(file_name)
    xml_file = File.new file_name
    doc = Document.new xml_file
    @root = doc.root
    @individuals = []
  end

  def self.load
    @root.elements.each {|individual| parse_individual individual }
    @individuals
  end

  def self.set_window(window)
    @window = window
  end

  def self.set_world_size(size)
    @world_size = size
  end

  def self.parse_individual(individual_elem)
#   return false unless elem.instance_of? Element
    individual_elem.elements.each { |element| parse_element element }
    @individuals << Individual.new(@window, @world_size, @position, @genotype, @phenotype)
    clear_temp
  end

  def self.parse_element(element)
    name = element.attributes['name']
    if    name == 'position'  then @position  = parse_position(element.text)
    elsif name == 'Genotype'  then @genotype  = parse_genotype element
    elsif name == 'Phenotype' then @phenotype = parse_phenotype element
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