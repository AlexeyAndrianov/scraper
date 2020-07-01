# frozen_string_literal: true

module Scraper
  class ProductUrlsFinder
    def initialize
      @all_products_urls = []
    end

    def find(pagination_urls)
      puts 'Finding products URLs'
      pagination_urls.each do |html|
        curl_page = Curl.get(html)
        parsed_page = Nokogiri::HTML(curl_page.body_str)
        parsed_page.xpath("//*[@id='product_list']/li[*]").each do |node|
          sections_html = Nokogiri::HTML(node.inner_html)
          html_a_tags = sections_html.xpath('//*/div[1]/div[2]/div[2]/div[1]/h2/a')
          product_link = html_a_tags.attribute('href').value
          puts "Product found - #{product_link}"
          @all_products_urls << product_link
        end
      end
      @all_products_urls
      puts 'Done'
    end

    private

    attr_reader :pagination_urls

  end
end
