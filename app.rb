require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'curb'
require 'nokogiri'

class PageParser
  def initialize(link)
    @web_page = link
    @all_products_urls = []
  end

  def parse
    puts "Parsing started:"
    find_all_category_pages

    # product_urls(html)
    puts @all_products_urls.length
    # products = []
    # product_urls(html).each do |page|
    #   puts "Getting CURL object from #{page}"
    #   products << Curl.get(page)
    # end
    # puts "Done"

    # parse_products(products)
    puts "Parsing successfully ended"
  end

  def find_all_category_pages
    pagination_urls = []
    i = 1
    # category_page = Curl.get(@web_page)
    # pagination_urls << Nokogiri::HTML(category_page.body_str)

    pagination_urls << Curl.get(@web_page)

    while pagination_curl.response_code == 200
      pagination_url = @web_page + "?p=#{i}"
      pagination_curl = Curl.get(pagination_url)
      pagination_urls << pagination_curl
      binding.pry
      i += 1
    end
      puts pagination_urls
  end

  # находим URL всех продуктов выбранной категории и сохраняем их в массиве result
  def product_urls(html)
    puts "Finding products URLs"
    html.xpath("//*[@id='product_list']/li[*]").each do |node|
      sections_html = Nokogiri::HTML(node.inner_html)
      html_a_tags = sections_html.xpath("//*/div[1]/div[2]/div[2]/div[1]/h2/a")
      product_link = html_a_tags.attribute("href").value
      puts "Product found - #{product_link}"
      @all_products_urls << product_link
    end
    puts @all_products_urls.length
    puts "Done"
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
