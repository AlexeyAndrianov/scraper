require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'curb'
require 'nokogiri'

class PageParser
  def initialize(link)
    @link = Curl.get(link)
  end

  # http = Curl.get('https://www.petsonic.com/snacks-huesos-para-perros/') do |http|
  #   http.headers['User-agent'] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
  # end

  def parse
    html = Nokogiri::HTML(@link.body_str)

    product_pages = []
    product_urls(html).each do |page|
      product_pages << Curl.get(page)
    end
    
    binding.pry
  end

  # находим URL всех продуктов выбранной категории и сохраняем их в массиве result
  def product_urls(html)
    result = []
    html.xpath("//*[@id='product_list']/li[*]").each do |node|
      sections_html = Nokogiri::HTML(node.inner_html)
      html_a_tags = sections_html.xpath("//*/div[1]/div[2]/div[2]/div[1]/h2/a").to_html
      result << html_a_tags.match(/http.+html/).to_s
    end
    result
  end
end

a = PageParser.new('https://www.petsonic.com/snacks-huesos-para-perros/')
a.parse
