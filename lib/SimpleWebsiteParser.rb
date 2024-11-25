require 'mechanize'
require 'yaml'
require 'logger'
require 'fileutils'
require 'json'
require 'csv'

class SimpleWebsiteParser
  attr_reader :config, :agent, :item_collection

  def initialize(config_file)
    @config = load_config(config_file)
    @agent = Mechanize.new
    @item_collection = []
    @logger = Logger.new('parser.log')
  end

  def load_config(config_file)
    YAML.load_file(config_file)
  end

  def start_parse
    @logger.info(@config)
    if @config['start_page'].nil? || @config['start_page'].empty?
      @logger.error('Не вказано URL стартової сторінки в конфігурації!')
      return
    end
    @logger.info("Парсинг стартує для URL: #{@config['start_page']}")
    if check_url_response(@config['start_page'])
      page = @agent.get(@config['start_page'])
      product_links = extract_products_links(page)
      parse_products(product_links)
    else
      @logger.error('Стартова сторінка недоступна.')
    end
  end

  def check_url_response(url)
    @logger.info("Sending request to URL: #{url}")
    response = @agent.get(url)
    @logger.info("Response code: #{response.code}")
    response.code.to_i == 200
  rescue StandardError => e
    @logger.error("Error checking URL #{url}: #{e.message}")
    false
  end

  def extract_products_links(page)
    @logger.info('Витягуємо посилання на продукти...')
    links = page.search(@config['product_links_selector']).map { |link| link['href'] }.uniq

    links.map! do |link|
      if link.start_with?('http')
        link
      else
        URI.join(page.uri.to_s, link).to_s
      end
    end

    @logger.info("#{links.size} посилань на продукти знайдено.")
    links
  end

  def parse_products(product_links)
    @logger.info('Парсинг сторінок продуктів...')
    threads = []
    product_links.each do |link|
      threads << Thread.new { parse_product_page(link) }
    end
    threads.each(&:join)
    save_all_data_to_csv # Save data to CSV after parsing is complete
  end

  def parse_product_page(product_link)
    @logger.info("Парсинг продукту: #{product_link}")
    if check_url_response(product_link)
      page = @agent.get(product_link)
      product = extract_product_details(page)
      @item_collection << product
      save_product_to_json(product) # Save product details to JSON file
    else
      @logger.error("Продукт #{product_link} недоступний.")
    end
  end

  def extract_product_details(product_page)
    {
      name: extract_product_name(product_page),
      price: extract_product_price(product_page),
      description: extract_product_description(product_page),
      image_url: extract_product_image(product_page),
      category: extract_product_category(product_page) # Dynamic category extraction
    }
  end

  def extract_product_name(product)
    product.search(@config['product_name_selector']).text.strip
  end

  def extract_product_price(product)
    product.search(@config['product_price_selector']).text.strip
  end

  def extract_product_description(product)
    product.search(@config['product_description_selector']).text.strip
  end

  def extract_product_image(product)
    image_element = product.search(@config['product_image_selector']).first
    if image_element.nil?
      @logger.error('Не знайдено зображення для продукту.')
      return nil
    end
    image_element['src']
  end

  def extract_product_category(product)
    product.search('.breadcrumb li:nth-child(3) a').text.strip
  rescue StandardError => e
    @logger.error("Не вдалося отримати категорію продукту: #{e.message}")
    'Default'
  end

  def save_product_to_json(product)
    category = product[:category] || 'uncategorized'
    dir_path = File.join('output', category)

    FileUtils.mkdir_p(dir_path) unless File.exist?(dir_path)

    json_filename = "#{product[:name].gsub(/[^0-9A-Za-z.\-]/, '_')}.json"
    json_path = File.join(dir_path, json_filename)

    File.write(json_path, product.to_json)
    @logger.info("Дані продукту збережено у JSON файл: #{json_path}")
  end

  def save_all_data_to_csv
    @logger.info('Зберігаємо всі дані у CSV файл...')
    csv_path = 'output/products_data.csv'
    headers = ['name', 'price', 'description', 'image_url', 'category']
    
    CSV.open(csv_path, 'wb', write_headers: true, headers: headers) do |csv|
      @item_collection.each do |product|
        csv << [product[:name], product[:price], product[:description], product[:image_url], product[:category]]
      end
    end

    @logger.info("Дані збережено у CSV файл: #{csv_path}")
  end
end
