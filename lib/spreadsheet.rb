module Spreadsheet
  class SpreadsheetError < Exception; end

  # Public: Return spreadsheet configuration
  def self.configure
    @configure || {}
  end

  # Public: Set spreadsheet configuration
  #
  # Examples
  #
  #   Spreadsheet.configure = {
  #     path: File.expand_path('../../spreadsheet.yml', __FILE__),
  #     spreadsheet_key: '0Aq6I3AMo8MZjdFN4ZHpacWxJODRjTF9vQ3FfUTVPSUE',
  #     user_name: 'user@gmail.com',
  #     password: 'password'
  #   }
  def self.configure= value
    @configure = value
  end

  # Public: Return meta config. Path to meta config file set in configuration (option :path)
  # Meta file is a yaml file and contains:
  #
  #  table_name - name of table
  #  type       - type of table (static or cube)
  #  worksheet  - number of worksheet
  #  at         - position of table left upper corner
  #
  # Examples
  #
  #   companies:
  #     type: static
  #     worksheet: 0
  #     at: A2
  def self.meta_config
    @meta_config ||= YAML.load_file(configure[:path]) if configure[:path]
  end

  # Public: Return tables as hash or table by name
  #
  # name - name of table or table comma list. If name is nil then all tables from meta file will be fetch.
  #
  # Return table hash values
  def self.tables name = nil
    unless name.blank?
      name.strip!

      if name.include? ','
        result = {}
        name.split(',').each { |table_name| result.merge! tables table_name }
        return result
      end

      raise SpreadsheetError, "No config for table #{name}" unless self.meta_config[name]
      return self.load_table name, self.meta_config[name]
    end

    result = {}
    self.meta_config.each { |name, config|
      table = load_table name, config
      if block_given?
        yield name, table
      else
        result.merge! table
      end
    }

    result
  end

  protected

  # Internal: Load table from spreadsheet by name and config
  #
  # name   - name of table
  # config - table configuration
  #
  # Return table hash values
  def self.load_table name, config
    worksheet_index = config['worksheet']
    unless cache.has_key? worksheet_index
      worksheet = self.worksheets worksheet_index
      cache[worksheet_index] = {
          worksheet: worksheet,
          rows: worksheet.rows
      }
    end

    cache_data = cache[worksheet_index]

    type = "Spreadsheet::#{config['type'].camelize}Table".constantize
    type.new(name, cache_data[:worksheet], cache_data[:rows], config).to_hash
  end

  # Internal: Return cache google spreadsheet session
  def self.session
    @session ||= GoogleDrive.login(self.configure[:user_name], self.configure[:password])
  end

  # Internal: Return cache google spreadsheet object
  def self.spreadsheet
    @spreadsheet ||= self.session.spreadsheet_by_key(self.configure[:spreadsheet_key])
  end

  def self.worksheets index
    cache_path = configure[:cache_path]
    if cache_path
      open(cache_path, 'w').write self.spreadsheet.worksheets[index].rows.to_yaml  unless File.exist? cache_path
      FileWorksheet.new configure[:cache_path]
    else
      self.spreadsheet.worksheets[index]
    end
  end

  # Internal: Return cache of worksheets objects and worksheets rows
  def self.cache
    @worksheets ||= {}
  end
end
