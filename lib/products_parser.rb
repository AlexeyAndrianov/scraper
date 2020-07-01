# frozen_string_literal: true

module Scraper
  class ProductsParser
    def intialize(urls)
      @urls = urls
    end

    def parse
      puts 'Products pages parsing started:'
      urls.each do |url|
        puts "Parsing #{url}"
        product_curl = Curl.get(url)
        parsed_product = Nokogiri::HTML(product_curl.body_str)
        parse_multiproducts(parsed_product)
      end
      puts 'Products pages parsing successfully ended'
    end

    private

    attr_reader :urls

    def parse_multiproducts(parsed_product)
      puts 'Parsing product variations'
      product_title = find_title(parsed_product)
      image = find_image(parsed_product)

      fieldsets = parsed_product.xpath("//*[@id='attributes']/fieldset[*]")

      fieldsets.each do |fieldset|
        product_group = Nokogiri::HTML(fieldset.inner_html)
        packing_type = product_group.text.match(/(?<pack>\w+)/)[:pack]

        product_group.xpath('//*/div/ul/li[*]').each do |node|
          packing_type = node.to_html.match(%r{(?<=important">).*?(?=</span>)})
          full_title = product_title + " - #{packing_type}"
          price = find_price(node).to_s
          @result << [full_title, image, price]
        end
      end
      @result
      puts 'Product variations parsed'
    end

    def find_title(parsed_product)
      parsed_product.xpath('//*/div/div[2]/div[2]/div[1]/div[2]/h1').text
    end

    def find_image(parsed_product)
      parsed_product.xpath("//*[@id='bigpic']").attribute('src').value
    end

    def find_price(parsed_product)
      parsed_product.to_html.match(%r{(?<=price_comb">).*?(?=</span>)})
    end
  end
end
