class Scrapers::Vinci < Scrapers::BaseScraper
  LOT_TYPES = {
    "4P" => "4 pièces",
    "3P" => "3 pièces",
    "2P" => "2 pièces",
    "1P" => "Studio",
    "5P" => "5 pièces",
    "3P/4P" => "3 pièces",
    "4P duplex" => "4 pièces duplex",
    "3P duplex" => "3 pièces duplex",
    "4P/5P" => "4 pièces",
    "Maison 3P" => "Maison 3 pièces",
    "1P bis" => "Studio",
    "Maison 5P" => "Maison 5 pièces",
    "5P duplex" => "5 pièces duplex",
    "Maison 4P" => "Maison 4 pièces",
    "6P duplex" => "6 pièces duplex"
  }.freeze

  def initialize
    @programme_ids = {}
    @lots_count = 0
  end

  def site_name
    'vinci'
  end

  def perform(from_page=0)
    puts "start scraping #{site.url}"
    session = Mechanize.new

    puts "login"
    login(session)

    i = from_page
    while true
      sleep(3)
      puts "process page #{i}"
      page_url = "#{site.url}/pages/lot/recherche_static.php?s_wbg_menu=102&rechercheSpecLot=1&l=fr&debut=#{i*100}"
      puts page_url
      page = session.get(page_url)
      result = process_page(session, page.body)
      break if result == false
      i += 1

      # Test 1 page
      # break
      # -----------
    end

    puts "Processed: #{@lots_count} lots"

    true
  end

  private

  def process_page(session, body)
    doc = Nokogiri::HTML(body)
    rows = doc.xpath("//table[@id='tableau_recherche_logement']/tr")
    puts rows.length

    return false if rows.length == 0

    i = 1
    rows.drop(1).collect do |row|
      puts "--------------------------"
      puts "lot #{i}"

      lot_link = row.at_xpath("td[1]/div[1]/a[1]/@href").value
      puts "lot_link: #{lot_link}"

      lot_source_id = lot_link.split('=').last
      puts "lot_source_id: #{lot_source_id}"

      lot = Lot.where(site_id: site.id, lot_source_id: lot_source_id).first_or_create
      get_lot_row(lot, row)

      # go to lot link
      process_lot_link(lot, session, lot_link)

      # save lot
      lot.save

      @lots_count += 1

      # Test 1 lot
      # break
      # -------------
      i += 1
    end

    true
  end

  def get_lot_row(lot, row)
    col1 = row.at_xpath("td[1]/div[1]").inner_html
    col1 =~ /a href=.*>(.*?)<\/a><br>(.*?)$/
    lot_name = $1
    puts "lot_name: #{lot_name}"
    lot.lot_name = lot_name

    dept_ville = $2.split('-')
    department = dept_ville[0].strip
    puts "department: #{department}"
    lot.department = department
    lot.region = region_for(department)

    ville = dept_ville[1].strip
    puts "ville: #{ville}"
    lot.ville = ville

    reference = row.at_xpath("td[2]/span[1]").inner_text
    puts "reference: #{reference}"
    lot.reference = reference

    type = row.at_xpath("td[3]").inner_text&.strip
    puts "type: #{type}"
    lot.lot_type = LOT_TYPES[type] || type

    superficie = row.at_xpath("td[4]").inner_text
    puts "superficie: #{superficie}"
    lot.superficie = superficie

    size = superficie.to_f
    puts "size: #{size}"
    lot.size = size

    price_text = row.at_xpath("td[5]").inner_text
    puts "price_text: #{price_text}"
    lot.price_text = price_text

    price = price_text.delete('€ ').to_i
    puts "price: #{price}"
    lot.price = price

    fiscalite = row.at_xpath("td[6]").inner_text.strip
    puts "fiscalite: #{fiscalite}"
    lot.fiscalite = fiscalite

    disponibilite = row.at_xpath("td[7]").inner_text.strip
    puts "disponibilite: #{disponibilite}"
    lot.disponibilite = disponibilite

    rentabilite = row.at_xpath("td[9]").inner_text.strip
    puts "rentabilite: #{rentabilite}"
    lot.rentabilite = rentabilite

    expected_actability = row.at_xpath("td[10]").inner_text.strip
    puts "expected_actability: #{expected_actability}"
    lot.expected_actability = expected_actability

    expected_delivery = row.at_xpath("td[11]").inner_text.strip
    puts "expected_delivery: #{expected_delivery}"
    lot.expected_delivery = expected_delivery
  end

  def process_lot_link(lot, session, lot_link)
    page = session.get(lot_link)
    doc = Nokogiri::HTML(page.body)

    address = doc.at_xpath("//div[@class='titrePageDonnee__sector_VIP_bleu_titre']")
    address ||= doc.at_xpath("//div[@class='titrePageDonnee__sector_VIP_bleu_titre text_recherche_haut_option']")
    address = address&.inner_text&.split('-')&.last&.strip
    puts "address: #{address}"
    lot.address = address

    content = doc.at_xpath("//div[@class='bloc-droite-type-prix']")&.inner_text&.delete("\n")
    content =~ / - (.*?) €/
    prix_ht = $1&.strip
    puts "prix_ht: #{prix_ht}"
    lot.prix_ht = prix_ht

    content = doc.at_xpath("//div[@class='bloc-droite-loyers']")&.inner_html
    # puts content
    content =~ /Loyer Pinel : (.*?) &#8364;/
    loyer_pinel = $1&.strip
    puts "loyer_pinel: #{loyer_pinel}"
    lot.loyer_pinel = loyer_pinel

    content =~ /Loyer annuel : (.*?) &#8364;/
    loyer_ht = $1&.strip
    puts "loyer_ht: #{loyer_ht}"
    lot.loyer_ht = loyer_ht

    content =~ /Prix mobilier : (.*?) &#8364;/
    prix_ht_mobilier = $1&.strip
    puts "prix_ht_mobilier: #{prix_ht_mobilier}"
    lot.prix_ht_mobilier = prix_ht_mobilier

    content =~ /Loyer de march.* : (.*?) &#8364;/
    loyer = $1&.strip
    puts "loyer: #{loyer}"
    lot.loyer = loyer

    content = doc.xpath("//div[@id='container-carousel-embed']/ul/li/a/img/@src")
    images = content.map(&:value).join(';') if content
    puts "images: #{images}"
    lot.images = images

    content = doc.at_xpath("//div[@id='bloc_gauche_fiche_lot']")&.inner_html

    content =~ /.*Etage : <span>(.*?)<\/span>/
    etage = $1&.strip
    puts "etage: #{etage}"
    lot.etage = etage

    content =~ /.*Exposition : <span>(.*?)<\/span>/
    exposition = $1&.strip
    puts "exposition: #{exposition}"
    lot.exposition = exposition

    content =~ /.*Zone fiscale : <span>(.*?)<\/span>/
    zone = $1&.strip
    puts "zone: #{zone}"
    lot.zone = zone

    content =~ /.*Taux TVA : <span>(.*?)<\/span>/
    vat_rate = $1&.strip
    puts "vat_rate: #{vat_rate}"
    lot.vat_rate = vat_rate

    content =~ /.*Terrasse : <span>(.*?)<\/span>/
    terrasse_text = $1&.strip
    puts "terrasse_text: #{terrasse_text}"
    lot.terrasse_text = terrasse_text

    content =~ /.*Jardin : <span>(.*?)<\/span>/
    jardin = $1&.strip
    puts "jardin: #{jardin}"
    lot.jardin = jardin

    content =~ /.*Balcon: <span>(.*?)<\/span>/
    balcon = $1&.strip
    puts "balcon: #{balcon}"
    lot.balcon = balcon

    content =~ /.*Parking : <span>(.*?)<\/span>/
    parking_text = $1&.strip
    puts "parking_text: #{parking_text}"
    lot.parking_text = parking_text

    content =~ /.*pot de garantie : <span>(.*?)<\/span>/
    depot_de_garantie = $1&.strip
    puts "depot_de_garantie: #{depot_de_garantie}"
    lot.depot_de_garantie = depot_de_garantie

    content =~ /.*Frais de notaire : <span>(.*?)<\/span>/
    frais_de_notaire = $1&.strip
    puts "frais_de_notaire: #{frais_de_notaire}"
    lot.frais_de_notaire = frais_de_notaire

    content = doc.at_xpath("//div[@class='container-boutons-programme-lot']")&.inner_html
    content =~ /location.href='(.*?)'/
    programme_link = $1
    puts "programme_link: #{programme_link}"

    # programme
    process_programme_link(lot, session, programme_link)
  end

  def process_programme_link(lot, session, programme_link)
    page = session.get(programme_link)
    doc = Nokogiri::HTML(page.body)
    content = doc.at_xpath("//div[@id='programme_data_tab']")&.inner_html

    content =~ /.*Nombre de lots total : <span>(.*?)<\/span>/
    logements = $1&.strip
    puts "logements: #{logements}"
    lot.logements = logements

    content =~ /.*PLS Possible : <span>(.*?)<\/span>/
    pls = $1&.strip
    puts "pls: #{pls}"
    lot.pls = pls
  end

  def login(session)
    page = session.get("#{site.url}/home/")
    form = page.forms.first
    form['s_login'] = 'romeo.maike@fiduce.fr'
    form['s_password'] = 'MAIKE2018'
    page = form.submit
  end
end
