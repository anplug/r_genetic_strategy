# frozen_string_literal: true

require 'rexml/document'

class Settings
  include REXML

  DEFAULT_FILE_NAME = 'data/settings.xml'

  def self.load
    file_name = Argv.get_parameter_value('inputFile') || DEFAULT_FILE_NAME

    @settings = {}
    @setting_pathes = {}

    doc = Document.new(File.new(file_name.to_s))
    doc.root.elements.each do |category|
      category.each { |elem| insert_record(category, elem) }
    end
  end

  # rubocop:disable Lint/DuplicateBranch, Metrics/AbcSize
  def self.insert_record(category_elem, elem)
    return false unless elem.instance_of?(Element)

    category = category_elem.attributes['name'].downcase.to_sym
    name = elem.attributes['name'].downcase.to_sym
    type = elem.attributes['type']
    value =
      case type
      when 'Float'   then elem.text.to_f
      when 'Hex'     then elem.text.to_i(16)
      when 'Integer' then elem.text.to_i
      when 'Bool'    then parse_bool(elem.text)
      when 'Color'   then elem.text
      else                elem.text
      end

    set_setting(category, name, value)
  end
  # rubocop:enable Lint/DuplicateBranch, Metrics/AbcSize

  def self.set_setting(category, name, value)
    puts "#{category} -> #{name}=#{value} (#{value.class})"
    @settings[category] = {} if @settings[category].nil?
    if @setting_pathes[name].nil?
      @setting_pathes[name] = [category]
    else
      @setting_pathes[name] << category
    end
    @settings[category][name] = value
  end

  def self.parse_bool(str)
    %w[false False].include?(str)
  end

  # Get settings here
  def self.method_missing(*args)
    name = args.first
    categories = @setting_pathes[name]

    raise "Property #{name} not found" if categories.nil?

    return @settings[categories.first][name] if categories.size == 1

    raise "No category provided for #{name} specify on of #{categories}" if args.size == 1

    category = args[1]

    unless categories.include?(category)
      raise "Wrong category provided for #{name} (:#{category}), specify one of #{categories}"
    end

    @settings[category][name]
  end

  def self.respond_to_missing?(method_name, _include_private = false)
    return false if @setting_pathes[method_name].nil?

    true
  end
end

S = Settings
