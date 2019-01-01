class Scrapers::IcadePrescripteurs < Scrapers::BaseScraper
  def initialize
    @programme_ids = []
  end

  def url
    'http://www.icade-prescripteurs.com'
  end

  def perform
    puts "start scraping #{url}"
    session = Mechanize.new

    puts "login"
    home_page = session.get(url)
    login(home_page)

    puts "get lots"
    lots_page = session.get("#{url}/pdm/offre/recherche/lots")
    i = 1
    while true
      puts "get lot links for page #{i}"

      lot_links = get_lot_links_for_page(session, i)
      break if lot_links.blank?

      # print lot_links
      lot_links.each do |link|
        lot_link = "#{url}#{link}"
        process_lot(session, lot_link)

        # test
        break
        # -----------
      end

      # test
      break
      # -----------

      i += 1
    end

    true
  end

  private

  def process_lot(session, link)
    puts "---------------"
    puts "process #{link}"

    # http://www.icade-prescripteurs.com/pdm/offre/programme,62291/pdmlot,44
    arr = link.split(',')
    programme_id = arr[1].split('/').first
    lot_id = arr.last

    unless @programme_ids.include? programme_id
      @programme_ids << programme_id
      process_programme(session, programme_id)
    end

    body = session.get(link).body
    html_doc = Nokogiri::HTML(body)
    list = html_doc.xpath("//ul[@class='annexes']/li")
    terrasse_text = list[1].text.split(':')[1].strip
    parking_text = list[2].text.split(':')[1].strip
    puts "Terrasse: #{terrasse_text}"
    puts "Parking: #{parking_text}"

    puts "---------------"
  end

  def process_programme(session, programme_id)
    # http://www.icade-prescripteurs.com/pdm/offre/programme,62291/visuels?width=870&height=580&start=0
    images_url = "#{url}/pdm/offre/programme,62291/visuels?width=870&height=580&start=0"
    puts "process #{images_url}"
    body = session.get(images_url).body
    html_doc = Nokogiri::HTML(body)
    images = html_doc.css("#myGallery").css('a[href]').map {|e| e['href']}
    puts "Images: #{images.join(';')}"
  end

  def get_lot_links_for_page(session, n)
    body = session.get("#{url}/pdm/offre/recherche/affiner?origin=page&page=#{n}").body

    html_doc = Nokogiri::HTML(body)
    list = html_doc.xpath("//td[@class='desc bl0']/p/a/@href")
    list.map(&:value)
  end

  def login(page)
    form = page.forms.first
    form['email'] = 'romeo.maike@fiduce.fr'
    form['password'] = 't3zf0qy2'
    page = form.submit

    puts page.title
    puts page.search('#btLot').text
  end
end
