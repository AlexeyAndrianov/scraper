# frozen_string_literal: true

require_relative 'lib/runner.rb'
require_relative 'lib/csv_writer.rb'
require_relative 'lib/category_pages_finder.rb'
require_relative 'lib/products_parser.rb'
require_relative 'lib/product_urls_finder.rb'

web_page = ARGV[0]
file_name = ARGV[1]

web_page = 'https://www.petsonic.com/snacks-huesos-para-perros/'
file_name = 'qwe.csv'
Scraper::Runner.new(web_page, file_name).perform
