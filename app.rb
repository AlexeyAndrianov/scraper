require 'rubygems'
require 'bundler/setup'
require 'csv'
Bundler.require(:default)

class PageParser
  def initialize(link)
    @web_page = link
    @all_products_urls = []
  end

  def parse
    puts "Parsing started:"

    # рабочий код скрипта. Нужно закомментить если надо проверить парсинг отдельных страниц товаров
    product_urls(find_all_category_pages)
    puts "Found #{@all_products_urls.length} product pages"
    result = parse_products(@all_products_urls)

    # # проблемные страницы для проверки парсинга мультистраниц.
    # # Нужно сделать так, чтобы все они и их разновидности нормально парсились:
    # parse_products(['https://www.petsonic.com/purina-pro-plan-adventuros-strips-venado-para-perros.html'])
    # parse_products(['https://www.petsonic.com/purina-pro-plan-adventuros-mini-sticks-bufalo-para-perros.html'])
    # parse_products(['https://www.petsonic.com/pedigree-dentastix-5-10-kg-sticks-dentales-para-perros.html'])
    # parse_products(['https://www.petsonic.com/siete-anos-snack.html'])
    # parse_products(['https://www.petsonic.com/purina-pro-plan-adventuros-sticks-bufalo-para-perros.html'])

    write_to_csv(result)
    puts "Parsing successfully ended"
  end

  def write_to_csv(result)
    puts "Writing in CSV"
    CSV.open('ruby-scrapp.csv', 'wb') do |csv|
      csv << ["Title", "Img", "Price"]
      result.each do |found_item|
        csv << found_item
      end
    end
    puts "Done"
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
  def parse_products(urls)
    result = []

    puts "Products pages parsing started:"
    urls.each do |url|
      puts "Parsing #{url}"

      product_curl = Curl.get(url)
      parsed_product = Nokogiri::HTML(product_curl.body_str)

      # check_product_page_type

      # check_fieldsets(parsed_product).each do |fieldset|
      #   find_multiproduct_urls(fieldset, url)
      # end

      title = find_title(parsed_product)
      image = find_image(parsed_product)
      price = find_price(parsed_product)

      result << [title, image, price]
    end
    puts "Done"
    result
  end


  private

  def check_product_page_type

  end

  def find_multiproduct_urls(fieldset, url)

    puts "Finding URLs product variations "
    multiproduct_urls = []

    i = 2
    packing_type = fieldset.xpath("//*/fieldset/label").text.gsub(/[[:space:]]/, '')
    binding.pry 
    # while i <= fieldset.xpath("//*[@id='attributes']/fieldset/div/ul/li[*]").count
    #   html_section = fieldset.xpath("//*[@id='attributes']/fieldset/div/ul/li[#{i}]")
    #   multiproduct_value = html_section.to_html.match(/value="(?<value>\d+)"/)[:value]
    #   multiproduct_name = html_section.xpath("//*/fieldset/div/ul/li[#{i}]/label/span[1]").text

    #   multiproduct_name = multiproduct_name.gsub(/[()]/, "").gsub(/\s+/,"-")

    #   multiproduct_url = url + "#/#{multiproduct_value}-#{packing_type}-#{multiproduct_name}"
    #   multiproduct_urls << multiproduct_url.downcase
    #   i += 1
    # end

    # puts "Found #{multiproduct_urls.length} additional product variations"

    multiproduct_urls
  end

  def check_fieldsets(parsed_product)
    parsed_product.xpath("//*[@id='attributes']/fieldset[*]")
  end

  def find_multuproduct_title(parsed_product)
    title = parsed_product.xpath("//*/div/div[2]/div[2]/div[1]/div[2]/h1").text
    i = 1

    checkbox = parsed_product.xpath("//*[@id='attributes']/fieldset/div/ul/li[#{i}]")
    while checkbox.inner_html.include?('checked')
      variety = parsed_product.xpath("//*[@id='attributes']/fieldset/div/ul/li[#{i}]/label/span[1]")
      i += 1
      checkbox = parsed_product.xpath("//*[@id='attributes']/fieldset/div/ul/li[#{i}]")
    end
    binding.pry
    full_title = title + " - #{variety.text}"
  end


  def find_title(parsed_product)
    title = parsed_product.xpath("//*/div/div[2]/div[2]/div[1]/div[2]/h1").text
    packing_type = parsed_product.xpath("//*[@id='attributes']/fieldset/div/ul/li[1]/label/span[1]")
    full_title = title + " - #{packing_type.text}"
  end

  def find_image(parsed_product)
    parsed_product.xpath("//*[@id='bigpic']").attribute("src").value
  end

  def find_price(parsed_product)
    parsed_product.xpath("//*/fieldset[1]/div/ul/li[1]/label/span[2]").text
  end

end

a = PageParser.new('https://www.petsonic.com/snacks-huesos-para-perros/')
a.parse
