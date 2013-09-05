module Spreadsheet
  class FileWorksheet
    def initialize(path)
      @rows = YAML.load_file path
    end

    def cell_name_to_row_col(position)
      position.upcase!

      column =  position[/[A-Z]+/]
      count = column.size
      column = column.chars.inject(0) do |sum, char|
        count -= 1
        char.upcase.bytes.first - 65 + 27 ** count + sum
      end
      [position[/\d+/].to_i, column]
    end

    def rows
      @rows
    end
  end
end