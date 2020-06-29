require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

class PageParser
  def initialize(link)
    @web_page = link
    @all_products_urls = []
  end

  def parse
    puts "Parsing started:"
    # product_urls(find_all_category_pages) # раскомменти эту строку для проверки всего парсера
    # puts "Find #{@all_products_urls.length} product pages" # раскомменти эту строку для проверки всего парсера
    # parse_products(@all_products_urls) # раскомменти эту строку для проверки всего парсера
    parse_products(['https://www.petsonic.com/pedigree-dentastix-5-10-kg-sticks-dentales-para-perros.html']) # закомменти
    puts "Parsing successfully ended"
  end

  # находим URL всех страниц пагинации категории
  def find_all_category_pages
    puts "Finding pagination pages"
    pagination_urls = []
    i = 2
    pagination_urls << @web_page
    page_url = @web_page + "?p=#{i}"

    while Curl.get(page_url).response_code == 200 do
      pagination_urls << page_url
      puts "Found #{i} category page"
      i += 1
      page_url = @web_page + "?p=#{i}"
    end

    puts "Done"
    pagination_urls
  end

  # находим URL всех продуктов выбранной категории и сохраняем их в массиве all_products_urls
  def product_urls(pagination_urls)
    puts "Finding products URLs"
    pagination_urls.each do |html|
      curl_page = Curl.get(html)
      parsed_page = Nokogiri::HTML(curl_page.body_str)
      parsed_page.xpath("//*[@id='product_list']/li[*]").each do |node|
        sections_html = Nokogiri::HTML(node.inner_html)
        html_a_tags = sections_html.xpath("//*/div[1]/div[2]/div[2]/div[1]/h2/a")
        product_link = html_a_tags.attribute("href").value
        puts "Product found - #{product_link}"
        @all_products_urls << product_link
      end
    end
    puts "Done"
  end

  # парсим все продукты и сохраняем нужные данные в массиве result
  def parse_products(products)
    result = []

    puts "Products pages parsing started:"
    products.each do |product|
      puts "Parsing #{product} page"
      # надо в процессе парсинга страницы товаров проверить наличие вариаций товаров, 
      # сгенерить их урлы и пропарсить эти вариации сразу после парсинга первой вариации товара
      product_curl = Curl.get(product)
      parsed_product = Nokogiri::HTML(product_curl.body_str)

      title = find_title(parsed_product)
      image = find_image(parsed_product)
      # price = find_price(parsed_product)
      binding.pry
      result << [title, image]
    end
    result
    puts "Done"
  end

  private

  def find_title(parsed_product)
    title = parsed_product.xpath("//*/div/div[2]/div[2]/div[1]/div[2]/h1").text
    i = 1

    checkbox = parsed_product.xpath("//*[@id='attributes']/fieldset/div/ul/li[#{i}]")
    while checkbox.inner_html.include?('checked')
      variety = parsed_product.xpath("//*[@id='attributes']/fieldset/div/ul/li[#{i}]/label/span[1]")
      i += 1
      checkbox = parsed_product.xpath("//*[@id='attributes']/fieldset/div/ul/li[#{i}]")
    end
    full_title = title + " - #{variety.text}"
  end

  def find_image(parsed_product)
    parsed_product.xpath("//*[@id='bigpic']").attribute("src").value
  end

  def find_price(parsed_product)
    parsed_product.xpath("//*[@id='attributes']/fieldset/div/ul")

  end

end

a = PageParser.new('https://www.petsonic.com/snacks-huesos-para-perros/')
a.parse
