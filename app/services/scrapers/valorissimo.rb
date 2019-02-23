class Scrapers::Valorissimo < Scrapers::BaseScraper
  LOT_TYPES = {
    "4p" => "4 pièces",
    "3p" => "3 pièces",
    "2p" => "2 pièces",
    "1p" => "Studio",
    "5p" => "5 pièces",
    "6p" => "6 pièces",
  }.freeze

  def initialize
    @programme_ids = {}
    @lots_count = 0
  end

  def site_name
    'valorissimo'
  end

  def perform(from_page=1)
    puts "start scraping #{site.url}"
    session = Mechanize.new

    puts "login"
    page = session.get(site.url)
    login(session, page)

    pages = get_pages(session)
    puts "pages count: #{pages}"

    (from_page..pages).each do |i|
      sleep(3)
      puts "process page #{i}"
      page_url = "#{site.url}/Recherche/Lots?PageIndex=#{i}&PageSize=50&IsAscending=True&SortExpression=NumeroLot&Pays=FR"
      puts page_url

      page = session.get(page_url)
      result = process_page(session, page.body, i)

      # Test 1 page
      # break
      # -----------
      puts "--------------------------"
    end

    puts "Processed: #{@lots_count} lots"

    true
  end

  private

  def process_page(session, body, page_no)
    doc = Nokogiri::HTML(body)
    rows = doc.xpath("//table/tr")
    puts rows.length

    i = 1
    rows.drop(1).collect do |row|
      puts "--------------------------"
      puts "page #{page_no}: lot #{i}"

      lot_link = row.at_xpath("td[1]/a[1]/@href").value
      puts "lot_link: #{lot_link}"
      lot_source_id = lot_link.split('=').last
      puts "lot_source_id: #{lot_source_id}"

      lot = Lot.where(site_id: site.id, lot_source_id: lot_source_id).first_or_create
      get_lot_row(lot, row)

      # go to lot link
      process_lot_link(lot, session, lot_link)

      lot.save

      @lots_count += 1

      # break
      i += 1
    end
  end

  def process_lot_link(lot, session, lot_link)
    page = session.get(lot_link)
    doc = Nokogiri::HTML(page.body)

    address = doc.at_xpath("//div[@class='mainContainer offreCont']/p[1]")&.inner_text.to_s.strip
    address = address.sub('      ', ', ').sub("\n", ' ').sub('         ', ' ')
    puts "address: #{address}"
    lot.address = address

    address =~ /, (.*?), /
    postal_code = $1&.strip
    puts "postal_code: #{postal_code}"
    lot.postal_code = postal_code

    images = doc.at_xpath("//div[@class='offreDetail']/img[1]/@src")&.value
    puts("images: #{images}")
    lot.images = images

    zone = doc.at_xpath("//div[@class='offreDetail']/ul[1]/li[1]/dl[1]/dt[2]")&.inner_text.to_s.strip.split(' ').last
    puts "zone: #{zone}"
    lot.zone = zone

    logement = doc.at_xpath("//div[@id='tabs-1']/div[1]/h4[1]").inner_text
    logement = logement.to_s.split(' ')[0]
    puts "logement: #{logement}"
    lot.logements = logement

    table_html = doc.at_xpath("//table[@class='tableAjout']").inner_html.delete("\n")

    table_html =~ /Parking \/ Cave.*?<td>(.*?)<br>/
    parking_text = $1
    puts "parking_text: #{parking_text}"
    lot.parking_text = parking_text

    table_html =~ /Loyer plafond Pinel.*?<td>(.*?)<\/td>/
    loyer_pinel = $1
    puts "loyer_pinel: #{loyer_pinel}"
    lot.loyer_pinel = loyer_pinel

    table_html =~ /Terrasse.*?<td>(.*?)<\/td>/
    terrasse_text = $1
    puts "terrasse_text:#{terrasse_text}"
    lot.terrasse_text = terrasse_text

    table_html =~ /Balcon.*?<td>(.*?)<\/td>/
    balcon = $1
    puts "balcon: #{balcon}"
    lot.balcon = balcon

    table_html =~ /Prix TTC.*?<td>(.*?)<\/td>/
    price_ttc = $1
    puts "price_ttc: #{price_ttc}"
    lot.price_ttc = price_ttc

    table_html =~ /Prix foncier.*?<td>(.*?)<\/td>/
    price_foncier = $1
    puts "price_foncier: #{price_foncier}"
    lot.price_foncier = price_foncier

    table_html =~ /Prix mobilier HT.*?<td>(.*?)<\/td>/
    prix_ht_mobilier = $1
    puts "prix_ht_mobilier: #{prix_ht_mobilier}"
    lot.prix_ht_mobilier = prix_ht_mobilier
  end

  def get_lot_row(lot, row)
    lot_name = row.at_xpath("td[1]/a[1]").inner_text
    puts "lot_name: #{lot_name}"
    lot.lot_name = lot_name

    lot_name =~ /(.*?)\((.*?)\)/
    ville = $1&.strip
    puts "ville: #{ville}"
    lot.ville = ville
    department = $2&.strip
    puts "department: #{department}"
    lot.department = department
    lot.region = region_for(department)

    reference = row.at_xpath("td[2]/a[1]").inner_text&.strip
    puts "reference: #{reference}"
    lot.reference = reference

    col4 = row.at_xpath("td[4]/a[1]").inner_text
    puts "col4: #{col4}"
    type = col4.split('/')[0].strip.delete(' ')
    puts "type: #{type}"
    lot.lot_type = LOT_TYPES[type] || type

    superficie = col4.split('/')[1]&.strip.to_s.sub('m²', '').strip.gsub('.', '').gsub(',', '.')
    puts "superficie: #{superficie}"
    lot.superficie = superficie

    size = superficie.to_f
    puts "size: #{size}"
    lot.size = lot.size

    etage = row.at_xpath("td[5]/a[1]").inner_text.to_s.split('/')[0].strip
    puts "etage: #{etage}"
    lot.etage = etage.to_i

    price_text = row.at_xpath("td[6]/a[1]").inner_text
    puts "price_text: #{price_text}"
    lot.price_text = price_text

    price = price_text.delete('€ ').to_i
    puts "price: #{price}"
    lot.price = price

    offre_speciale = row.at_xpath("td[6]/a[2]")&.inner_text
    offre_speciale = offre_speciale ? "Oui" : "Non"
    puts "offre_speciale: #{offre_speciale}"
    lot.offre_speciale = offre_speciale

    fiscalite = row.at_xpath("td[7]/a[1]").inner_text.strip
    puts "fiscalite: #{fiscalite}"
    lot.fiscalite = fiscalite

    expected_delivery = row.at_xpath("td[8]/a[1]").inner_text.strip
    puts "expected_delivery: #{expected_delivery}"
    lot.expected_delivery = expected_delivery

    col9 = row.at_xpath("td[9]/a[1]").inner_text
    puts "col9: #{col9}"
    rentabilite = col9.split('/')[0].strip
    lot.rentabilite = rentabilite
    puts "rentabilite: #{rentabilite}"
    loyer = col9.split('/')[1].strip
    puts "loyer: #{loyer}"
    lot.loyer = loyer

    disponibilite = row.at_xpath("td[10]/a[1]").inner_text.strip
    puts "disponibilite: #{disponibilite}"
    lot.disponibilite = disponibilite
  end

  def get_pages(session)
    page = session.get("#{site.url}/Recherche/Lots?")
    doc = Nokogiri::HTML(page.body)
    pages = doc.xpath("//ul[@class='pagination']/li/a/@href")
    last_page_link = pages[-2].value
    last_page_link =~ /PageIndex=(.*?)\&/
    puts(last_page_link)

    $1.to_i
  end

  def login(session, page)
    form = page.forms.first
    form['Name'] = 'MARO'
    form['Password'] = 'Jesuisvalorissimo1@'
    page = form.submit
  end
end
