require 'rexml/document'

class DataLoader
	include REXML

	def self.load(file_name)
    xml_file = File.new file_name
    doc = Document.new xml_file
    doc.root.elements.each do |cls|
			cls.each {|elem| insert_record cls, elem }
		end
	end
	
	def self.insert_record(cls, elem)
		return false unless elem.instance_of? Element
		cls_name  = cls.attributes['name']
    name = elem.attributes['name']
		type = elem.attributes['type']
		value = if 		  type == 'Float' 		then elem.text.to_f
						elsif 	type == 'Hex' 			then elem.text.to_i(16)
            elsif 	type == 'Integer' 	then elem.text.to_i
            elsif   type == 'Bool'      then parse_bool elem.text
						else 												 		 elem.text
						end
				
		inject_variable cls_name, name, value
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