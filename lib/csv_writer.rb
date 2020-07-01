# frozen_string_literal: true

module Scraper
  class CsvWriter
    def initialize(result)
      @result = result
    end

    def write_to_csv(pagination_urls)
      puts 'Writing in CSV'
      CSV.open(@file_name, 'wb') do |csv|
        csv << %w[Title Img Price]
        result.each do |found_item|
          csv << found_item
        end
      end
      puts 'Done'
    end

    private

    attr_reader :result

  end
end
