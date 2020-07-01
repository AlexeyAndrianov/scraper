# frozen_string_literal: true

module Scraper
  class Runner
    def initialize(web_page, file_name)
      @web_page = web_page
      @file_name = file_name 
    end

    def perform
      puts 'Parsing started:'

      @all_products_urls = product_urls_finder.find(category_pages)
      write_to_csv(parsed_products)
    end

    private

    attr_reader :web_page, :file_name, :all_products_urls

    def category_pages(web_page)
      Scraper::CategoryPagesFinder.new(web_page).perform
    end

    def product_urls_finder
      Scraper::ProductUrlsFinder.new
    end

    def parsed_products
      Scraper::ProductsParser.new(all_products_urls).parse
    end
  end
end
