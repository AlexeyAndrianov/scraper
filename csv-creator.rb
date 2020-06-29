# frozen_string_literal: true

require 'csv'

class CSVcreator
  def create_csv
    CSV.open('ruby-scrapp.csv', 'wb') do |csv|
      csv << ['stock']
      csv << ['stock', 'stack']
    end
  end
end
