module Spreadsheet
  class StaticTable
    include Converter

    def initialize(name, worksheet, rows, options = {})
      @name = name
      @worksheet = worksheet
      @rows = rows
      @position = options['at']
    end

    def to_hash
      result = {}
      result[@name.to_sym] = values
      result
    end

    protected

    def fields
      return @fields unless @fields.nil?

      position = @worksheet.cell_name_to_row_col @position
      @fields = []
      rows[position[0] - 1][(position[1] - 1)..-1].each do |column|
        break if column.empty?
        @fields << normalize(column)
      end

      @fields
    end

    def values
      position = @worksheet.cell_name_to_row_col @position
      result = []
      rows[position[0]..-1].each do |row|
        break if row[position[1] - 1].empty?
        value = {}
        fields.each_with_index do |field, index| 
          value[field.to_sym] = convert row[index + position[1] - 1]
        end
        result << value
      end

      result
    end

    def rows
      @rows
    end
  end
end