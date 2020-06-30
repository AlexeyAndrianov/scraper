require 'rubygems'
require 'bundler/setup'
require 'csv'
Bundler.require(:default)

class PageParser
    # этот метод можно рефакторить
  def initialize(link)
    @web_page = link
    @all_products_urls = []
  end

  def parse
    puts "Parsing started:"

    # # рабочий код скрипта. Нужно закомментить если надо проверить парсинг отдельных страниц товаров
    # product_urls(find_all_category_pages)
    # puts "Found #{@all_products_urls.length} product pages"
    # result = parse_products(@all_products_urls)

    # проблемные страницы для проверки парсинга мультистраниц.
    # Нужно сделать так, чтобы все они и их разновидности нормально парсились:
    parse_products(['https://www.petsonic.com/pedigree-dentastix-5-10-kg-sticks-dentales-para-perros.html']) # 3 товара у одной фасовки
    parse_products(['https://www.petsonic.com/purina-pro-plan-adventuros-sticks-bufalo-para-perros.html']) # 2 фасовки
    parse_products(['https://www.petsonic.com/purina-pro-plan-snack-dentalife-mini-para-perros.html']) # разные картинки

    # write_to_csv(result)
    puts "Parsing successfully ended"
  end

    # этот метод можно рефакторить
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
    # этот метод можно рефакторить
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
    # этот метод можно рефакторить
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


      find_multiproduct_urls(parsed_product, url)


      # title = find_title(parsed_product)
      # image = find_image(parsed_product)
      # price = find_price(parsed_product)

      # result << [title, image, price]

      # fieldsets = check_fieldsets(parsed_product)

      # if fieldsets.count > 1
      #   fieldsets.delete(fieldsets[0]) # удаляем первую разновидность товара, 
      #                                  #т.к. мы её уже пропарсили и добавили в result
      # end

      # fieldsets.each do |fieldset|
      #   find_multiproduct_urls(fieldset, url)
      # end


    end
    puts "Done"
    result
  end



  private

  # этот метод работает и генерит урлы нормально. Но от этого нет смысла, можно попробовать
  # переделать таким образом чтобы на выходе иметь массивы с именем, пикчей и ценой
  # проблема только в том, что хз как получить нужную пикчу для товара, БЛЯ! (а может забить болтяру? хмм)
  # ПО ФАКТУ ОСТАЛОСЬ ТОЛЬКО ПРИДУМАТЬ КАК ВЫДРАТЬ УРЛ НУЖНОЙ ПИКЧИ, ЁБА
  # потом просто нужно будет вызвать метод flatten на итоговом массиве в методе parse_products
  def find_multiproduct_urls(parsed_product, url)
    puts "Finding URLs product variations "
    multiproduct_urls = []
    fieldsets = parsed_product.xpath("//*[@id='attributes']/fieldset[*]")

    fieldsets.each do |fieldset|
      product_group = Nokogiri::HTML(fieldset.inner_html)
      packing_type = product_group.text.match(/(?<pack>\w+)/)[:pack]

      product_group.xpath("//*/div/ul/li[*]").each do |node|
        multiproduct_value = node.to_html.match(/value="(?<value>\d+)"/)[:value]
        multiproduct_name = node.to_html.match(/(?<=important">).*?(?=<\/span>)/).to_s
        multiproduct_name = multiproduct_name.gsub(/[().]/, "").gsub(/\s+/,"_")
        multiproduct_url = url + "#/#{multiproduct_value}-#{packing_type}-#{multiproduct_name}"
        multiproduct_urls << multiproduct_url.downcase
      end

    end

    puts "Found #{multiproduct_urls.length} additional product variations"
    binding.pry
    multiproduct_urls
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
