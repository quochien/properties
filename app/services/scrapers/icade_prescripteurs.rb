class Scrapers::IcadePrescripteurs < Scrapers::BaseScraper
  def initialize
    @programme_ids = {}
    @lots_count = 0
  end

  def site_name
    'icade-prescripteurs'
  end

  def perform
    puts "start scraping #{site.url}"
    session = Mechanize.new

    puts "login"
    home_page = session.get(url)
    login(home_page)

    puts "get lots"
    lots_page = session.get("#{site.url}/pdm/offre/recherche/lots")

    i = 1
    while true
      result = process_page(session, i)
      break if result == false
      i += 1
    end

    puts "Processed: #{@lots_count} lots"

    true
  end

  private

  def process_page(session, n)
    puts "processing page #{n}"
    body = session.get("#{site.url}/pdm/offre/recherche/affiner?origin=page&page=#{n}").body

    html_doc = Nokogiri::HTML(body)
    lot_links = html_doc.xpath("//td[@class='desc bl0']/p/a/@href").map(&:value)
    return false if lot_links.size == 0

    rows = html_doc.xpath('//table/tbody/tr')
    rows.drop(1).collect do |row|
      lot_link = row.at_xpath("td[2]/p[1]/a[1]/@href")
      next if lot_link == nil

      lot_link = "#{site.url}#{lot_link}"
      puts "lot_link: #{lot_link}"

      lot_name = row.at_xpath("td[2]/p[1]/a[1]/text()")
      puts "lot_name: #{lot_name}"

      lot_full_desc = row.at_xpath("td[2]/p[2]").inner_html
      puts "full_desc: #{lot_full_desc}"

      city = row.at_xpath("td[3]/p[1]").inner_html.sub('<br>', ' ')
      puts "city: #{city}"

      expected_delivery = row.at_xpath("td[4]/p[1]").inner_html.sub('<br>', '').strip
      puts "expected_delivery: #{expected_delivery}"

      expected_actability = row.at_xpath("td[5]/p[1]").inner_html.sub('<br>', '').strip
      puts "expected_actability: #{expected_actability}"

      price_text = row.at_xpath("td[6]").inner_text.squish #.sub('<br>', '').strip
      puts "price_text: #{price_text}"

      lot = process_lot(session, lot_link)
      lot.lot_name = lot_name
      lot.full_desc = lot_full_desc
      lot.city_text = city
      lot.expected_delivery = expected_delivery
      lot.expected_actability = expected_actability
      lot.price_text = price_text
      lot.save

      @lots_count += 1

      puts "-------------------------------------------"
      # break
    end

    puts "*********************************"

    true
  end

  def process_lot(session, link)
    # http://www.icade-prescripteurs.com/pdm/offre/programme,62291/pdmlot,44
    arr = link.split(',')
    programme_id = arr[1].split('/').first
    lot_id = arr.last

    unless @programme_ids.keys.include? programme_id
      programme = process_programme(session, programme_id)
      @programme_ids[programme_id] = programme
    end
    programme = @programme_ids[programme_id]

    body = session.get(link).body
    html_doc = Nokogiri::HTML(body)

    list = html_doc.xpath("//ul[@class='annexes']/li")
    terrasse_text = list[1].text.split(':')[1].strip rescue nil
    parking_text = list[2].text.split(':')[1].strip rescue nil
    puts "Terrasse: #{terrasse_text}"
    puts "Parking: #{parking_text}"

    list = html_doc.xpath("//span[@class='montant']")
    notary_fee = list[0].text rescue nil
    security_deposit = list[1].text rescue nil
    puts "notary_fee: #{notary_fee}"
    puts "security_deposit: #{security_deposit}"

    # save / update lot
    lot = Lot.where(
      site_id: site.id,
      programme_id: programme.id,
      lot_source_id: lot_id,
      programme_source_id: programme_id
    ).first_or_create
    lot.terrasse_text = terrasse_text
    lot.parking_text = parking_text
    lot.images = programme.images
    lot.notary_fee = notary_fee
    lot.security_deposit = security_deposit
    # lot.save
    lot
  end

  def process_programme(session, programme_id)
    # http://www.icade-prescripteurs.com/pdm/offre/programme,62291/visuels?width=870&height=580&start=0
    images_url = "#{site.url}/pdm/offre/programme,#{programme_id}/visuels?width=870&height=580&start=0"
    puts "process #{images_url}"
    body = session.get(images_url).body
    html_doc = Nokogiri::HTML(body)
    images = html_doc.css("#myGallery").css('a[href]').map {|e| e['href']}
    puts "Images: #{images.join(';')}"

    # insert / update programme
    programme = Programme.where(
      source_id: programme_id, site_id: site.id
    ).first_or_create
    programme.images = images.join(';')
    programme.save
    programme
  end

  def get_lot_links_for_page(session, n)
    body = session.get("#{site.url}/pdm/offre/recherche/affiner?origin=page&page=#{n}").body

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

  def site
    @site ||= Site.find_by(site_name: 'icade-prescripteurs')
  end
end
