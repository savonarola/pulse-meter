module Enumerable
  require 'csv'
  require 'terminal-table'

  def convert_time
    map do |el|
      if el.is_a?(Time)
        el.to_i
      else
        el
      end
    end
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
