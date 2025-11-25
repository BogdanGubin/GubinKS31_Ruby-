require "roo"
require "csv"

module MyGem
  class Converter
    def initialize(source_xlsx, target_csv, decimal: ".", date_format: "%Y-%m-%d")
      @source_xlsx = source_xlsx
      @target_csv  = target_csv
      @decimal     = decimal
      @date_format = date_format
    end

    def convert
      xlsx = Roo::Spreadsheet.open(@source_xlsx)

      CSV.open(@target_csv, "w") do |csv|
        xlsx.each_row_streaming do |row|
          csv << row.map { |cell| normalize(cell&.value) }
        end
      end
    end

    private

    def normalize(value)
      return "" if value.nil?

 
      if value.is_a?(Date) || value.is_a?(DateTime) || value.is_a?(Time)
        return value.strftime(@date_format)
      end


      if value.is_a?(Numeric)
        return value.to_s.gsub(".", @decimal)
      end

      value.to_s
    end
  end
end
