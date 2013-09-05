module Spreadsheet
  class CubeTable
    include Converter

    def initialize(name, worksheet, rows, options = {})
      @name = name
      @worksheet = worksheet
      @rows = rows
      @position = options['at']
      @time_position = options['time_at']
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
      end_column = @worksheet.cell_name_to_row_col(@time_position)[1]
      @fields = []
      rows[position[0]][(position[1] - 1)..(end_column - 2)].each do |column|
        break if column.empty?
        @fields << normalize(column)
      end

      @fields
    end

    def times
      return @times unless @times.nil?

      position = @worksheet.cell_name_to_row_col @time_position
      @times = []
      rows[position[0]-1][(position[1] - 1)..-1].each do |column|
        break if column.empty?
        @times << column.to_i
      end

      @times
    end

    def times_name
      position = @worksheet.cell_name_to_row_col(@time_position)
      @time_names ||= normalize rows[position[0] - 2][position[1] - 1]
    end

    def values
      position = @worksheet.cell_name_to_row_col @position
      time_position = @worksheet.cell_name_to_row_col @time_position
      result = []
      rows[(position[0] + 1)..-1].each do |row|
        break if row[position[1] - 1].empty?

        times.each_with_index do |time, time_index|
          value = {}
          fields.each_with_index do |field, index|
            value[field.to_sym] = convert row[index + position[1] - 1]
          end

          value[times_name.to_sym] = time
          value[:value] = convert row[time_index + time_position[1] - 1]

          result << value
        end

      end
      result
    end

    def rows
      @rows
    end
  end
end