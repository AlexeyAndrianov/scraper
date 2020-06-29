require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'curb'
require 'nokogiri'

class PageParser
  def initialize(link)
    @web_page = Curl.get(link)
  end

  # http = Curl.get('https://www.petsonic.com/snacks-huesos-para-perros/') do |http|
  #   http.headers['User-agent'] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
  # end

  def parse
    puts "Parsing started:"
    html = Nokogiri::HTML(@web_page.body_str)

    
    products = []
    product_urls(html).each do |page|
      puts "Getting CURL object from #{page}"
      products << Curl.get(page)
    end
    puts "Done"

    parse_products(products)
    puts "Parsing successfully ended"
  end

  # находим URL всех продуктов выбранной категории и сохраняем их в массиве result
  def product_urls(html)
    result = []
    puts "Finding products URLs"
    html.xpath("//*[@id='product_list']/li[*]").each do |node|
      sections_html = Nokogiri::HTML(node.inner_html)
      html_a_tags = sections_html.xpath("//*/div[1]/div[2]/div[2]/div[1]/h2/a")
      product_link = html_a_tags.attribute("href").value
      puts "Product found - #{product_link}"
      result << product_link
    end
    puts "Done"
    result
  end

  def parse_products(products)
    result = []

    puts "Products pages parsing started:"
    products.each do |product|
      puts "Parsing #{product} page"
      product_html = Nokogiri::HTML(product.body_str)
      title = product_html.xpath("//*[@id='center_column']/div/div[2]/div[2]/div[1]/div[2]/h1").text
      image = product_html.xpath("//*[@id='bigpic']").attribute("src").value
      # price = product_html.xpath("//*[@id='attributes']/fieldset/div/ul")
      result << [title, image]

    end
    result
    puts "Done"
  end

end

a = PageParser.new('https://www.petsonic.com/snacks-huesos-para-perros/')
a.parse
