module Enumerable
  require 'csv'
  require 'terminal-table'

  def convert_time
    map {|el| el.is_a?(Time) ? el.to_i : el}
  end

  def to_table(format = nil)
    if "csv" == format.to_s
      CSV.generate(:col_sep => ';') do |csv|
        self.each {|row| csv << row.convert_time}
      end
    else
      self.each_with_object(Terminal::Table.new) do |row, table|
        table << if row.respond_to?(:map)
          row.map(&:to_s)
        else
          row
        end
      end
    end
  end
end
