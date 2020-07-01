# frozen_string_literal: true

module Scraper
  class CategoryPagesFinder
    def intialize(web_page)
      @web_page = web_page
    end

    def perform
      puts 'Finding pagination pages'
      pagination_urls = []
      i = 2
      pagination_urls << @web_page
      page_url = @web_page + "?p=#{i}"

      while Curl.get(page_url).response_code == 200
        pagination_urls << page_url
        puts "Found #{i} category page"
        i += 1
        page_url = @web_page + "?p=#{i}"
      end

      puts 'Done'
      pagination_urls
    end
  end
end
