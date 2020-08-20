require 'rexml/document'
require_relative '../utils/argv_processor.rb'

class DataLoader
  include REXML
  extend ArgvProcessor

  DEFAULT_FILE_NAME = 'data/data.xml'

  def self.load
    file_name = get_parameter_value('inputFile') || DEFAULT_FILE_NAME
    xml_file = File.new(file_name)
    doc = Document.new(xml_file)
    doc.root.elements.each do |cls|
      cls.each { |elem| insert_record cls, elem }
    end
  end

  def self.insert_record(cls, elem)
    return false unless elem.instance_of? Element
    cls_name = cls.attributes['name']
    name = elem.attributes['name']
    type = elem.attributes['type']
    value =
      case(type)
        when 'Float'   then elem.text.to_f
        when 'Hex'     then elem.text.to_i(16)
        when 'Integer' then elem.text.to_i
        when 'Bool'    then parse_bool(elem.text)
        when 'Color'   then elem.text
        else                elem.text
      end

    inject_variable(cls_name, name, value)
  end

  def self.inject_variable(cls_name, name, value)
    puts "#{cls_name} <-- #{name}=#{value} (#{value.class})"
    eval(cls_name).const_set(name, value)
  end

  def self.parse_bool(str)
    if str == 'false' || str == 'False'
      false
    else
      true
    end
  end
end
