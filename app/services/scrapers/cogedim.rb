class Scrapers::Cogedim < Scrapers::BaseScraper
  def initialize
    @programme_ids = {}
    @lots_count = 0
  end

  def site_name
    'cogedim'
  end

  def perform(from_page = 2)
    Lot.where(site_id: site.id).update_all(enabled: false) if from_page == 2

    puts "start scraping #{site.url}"
    session = Mechanize.new

    puts "login"
    page = session.get(site.url)
    login(session)
    puts page.title

    puts "get lots"
    puts "submit to get page 1"
    page = session.get(site.url)
    # have to submit to get page 1
    form = page.forms.first
    page = form.submit
    process_page(session, page.body) if from_page == 2

    i = from_page
    while true
      sleep(3)
      puts "process page #{i}"
      page = session.get("#{site.url}/recherche/page/#{i}/")
      result = process_page(session, page.body)
      break if result == false
      i += 1
    end

    puts "Processed: #{@lots_count} lots"

    true
  end

  private

  def process_page(session, body)
    doc = Nokogiri::HTML(body)
    program_links = doc.xpath("//div[@class='program-button flex-justify-end']/a/@href").map(&:value)
    return false if program_links.empty?

    program_links.each do |link|
      process_programme(session, link)

      # test first programme
      # break
    end

    # false
    true
  end

  def process_programme(session, link)
    puts "****************************"
    puts "process #{link}"

    page = session.get(link)
    doc = Nokogiri::HTML(page.body)

    images = doc.xpath("//div[@class='visuel']/img/@src").map(&:value)
    # insert / update programme
    programme_id = link.split('/').last
    programme = Programme.where(
      source_id: programme_id, site_id: site.id
    ).first_or_create
    programme.url = link
    programme.images = images.join(';')
    programme.save

    ville_postal_code = doc.xpath("//div[@class='program-text']/h3").inner_text.strip
    postal_code = ville_postal_code.split(' ').last
    ville = ville_postal_code.delete(postal_code).strip

    puts "ville: #{ville}"
    puts "postal_code: #{postal_code}"

    dates = doc.xpath("//div[@class='col-md-4 col-lg-3 dates']").inner_html
    dates =~ /Date d’actabilité.*\n.*b>(.*)<\/b/
    expected_actability = $1&.strip
    puts "expected_actability: #{expected_actability}"

    infos = doc.xpath("//ul[@class='infos-right']").inner_html

    infos =~ /LOGEMENTS.*\n.*br>(.*)<\/li/
    logements = $1&.strip
    puts "logements: #{logements}"

    infos =~ /pleine propriété.*\n.*br>(.*)<\/li/
    pleine_propriete = $1&.strip
    puts "pleine_propriete: #{pleine_propriete}"

    infos =~ /Usufruitier.*\n.*br>(.*)<\/li/
    usufruitier = $1&.strip
    puts "usufruitier: #{usufruitier}"

    infos =~ /Usufruit temporaire.*\n.*br>(.*)<\/li/
    duree_usufruit_temporaire = $1&.strip
    puts "duree_usufruit_temporaire: #{duree_usufruit_temporaire}"

    infos =~ /ZONE FISCALE.*\n.*br>(.*)<\/li/
    zone = $1&.strip
    puts "zone: #{zone}"

    infos =~ /FISCALIT.*\n.*strong>(.*)<\/strong/
    unless $1
      infos =~ /ACHAT EN.*\n.*link-purple">(.*)<\/a/
    end
    fiscalite = $1&.delete('→')&.strip&.split('/')&.first&.sub('Loi ', '')
    puts "fiscalite: #{fiscalite}"

    infos =~ /GESTIONNAIRE.*\n.*br>(.*)<\/li/
    gestionnaire = $1&.strip
    puts "gestionnaire: #{gestionnaire}"

    infos =~ /DU BAIL.*\n.*br>(.*)<\/li/
    dureedubail = $1&.strip
    puts "dureedubail: #{dureedubail}"

    # lots
    # rows = doc.xpath("//table[@class='table table-condensed grille-lots firefox']/tbody/tr[@class='ligne-lot']")
    rows = doc.xpath("//table[@class='table table-condensed grille-lots']/tbody/tr[@class='ligne-lot']")

    if rows.length > 0
      if rows.first.at_xpath("td[14]").present?
        has_prix_fonicer = doc.xpath("//tr[@class='head-lot']").inner_text&.include?("Prix Foncier")
        if has_prix_fonicer
          parse_lots_fonicer(rows, programme, ville_postal_code, postal_code, ville, fiscalite, zone, logements, pleine_propriete, usufruitier, duree_usufruit_temporaire, gestionnaire, dureedubail, expected_actability)
        else
          parse_lots_new(rows, programme, ville_postal_code, postal_code, ville, fiscalite, zone, logements, pleine_propriete, usufruitier, duree_usufruit_temporaire, gestionnaire, dureedubail, expected_actability)
        end
      else
        parse_lots(rows, programme, ville_postal_code, postal_code, ville, fiscalite, zone, logements, pleine_propriete, usufruitier, duree_usufruit_temporaire, gestionnaire, dureedubail, expected_actability)
      end
    end
  end

  def parse_lots(rows, programme, ville_postal_code, postal_code, ville, fiscalite, zone, logements, pleine_propriete, usufruitier, duree_usufruit_temporaire, gestionnaire, dureedubail, expected_actability)
    lot_ids = rows.xpath("//tr/@id").map(&:value)
    i = 0
    rows.each do |row|
      if row.at_xpath("td[13]").present?
        disponibilite = row.at_xpath("td[13]").inner_html
      else
        disponibilite = row.at_xpath("td[9]").inner_html
      end
      disponibilite = !disponibilite.include?('error')

      lot_id = lot_ids[i]
      # save / update lot
      lot = Lot.where(
        site_id: site.id,
        programme_id: programme.id,
        lot_source_id: lot_id,
        programme_source_id: programme.source_id
      ).first_or_create

      lot.enabled = true
      lot.expected_actability = expected_actability
      lot.logements = logements
      lot.pleine_propriete = pleine_propriete
      lot.usufruitier = usufruitier
      lot.duree_usufruit_temporaire = duree_usufruit_temporaire
      lot.gestionnaire = gestionnaire
      lot.dureedubail = dureedubail

      puts "--------------------------"
      puts "lot #{i+1}: id #{lot_id}"
      reference = row.at_xpath("td[1]").inner_text
      puts "reference: #{reference}"
      lot_type = row.at_xpath("td[2]").inner_text
      puts "lot_type: #{lot_type}"

      # floor Rez de chaussée = ground floor = 0
      etage = row.at_xpath("td[3]").inner_text.split(' ').first.to_i
      puts "etage: #{etage}"

      # superficie = size
      superficie = row.at_xpath("td[4]").inner_text
      puts "superficie: #{superficie}"
      size = superficie.split(' ').first.sub('.', '').sub(',', '.').to_f
      puts "size: #{size}"

      terrasse_text = row.at_xpath("td[5]").inner_html
      puts "terrasse_text: #{terrasse_text}"

      price_text = row.at_xpath("td[6]").inner_text
      puts "price_text: #{price_text}"
      price = price_text.delete('€').delete(' ').to_i
      puts "price: #{price}"

      parking_text = row.at_xpath("td[7]").inner_text
      puts "parking_text: #{parking_text}"

      lot.images = programme.images
      lot.city_text = ville_postal_code
      lot.ville = ville
      lot.postal_code = postal_code
      lot.department = lot.postal_code.first(2)
      lot.region = region_for(lot.department)
      lot.zone = zone
      lot.fiscalite = fiscalite
      lot.reference = reference
      lot.lot_type = lot_type
      lot.etage = etage
      lot.superficie = superficie
      lot.size = size
      lot.terrasse_text = terrasse_text
      lot.price_text = price_text
      lot.price = price
      lot.parking_text = parking_text
      lot.disponibilite = disponibilite ? "Yes" : "No"

      if row.at_xpath("td[13]").present?
        market_rental = row.at_xpath("td[8]").inner_text
        puts "market_rental: #{market_rental}"

        rentabilite = row.at_xpath("td[9]").inner_text
        puts "rentabilite: #{rentabilite}"

        pinel_rental = row.at_xpath("td[10]").inner_text
        puts "pinel_rental: #{pinel_rental}"

        pinel_rentabilite = row.at_xpath("td[11]").inner_text
        puts "pinel_rentabilite: #{pinel_rentabilite}"

        expected_delivery = row.at_xpath("td[12]").inner_text
        puts "expected_delivery: #{expected_delivery}"
      else
        expected_delivery = row.at_xpath("td[8]").inner_text
        puts "expected_delivery: #{expected_delivery}"
      end

      puts "disponibilite: #{disponibilite}"

      lot.market_rental = market_rental
      lot.rentabilite = rentabilite
      lot.pinel_rental = pinel_rental
      lot.pinel_rentabilite = pinel_rentabilite
      lot.expected_delivery = expected_delivery
      lot.save

      @lots_count += 1

      i += 1
    end
  end

  def parse_lots_fonicer(rows, programme, ville_postal_code, postal_code, ville, fiscalite, zone, logements, pleine_propriete, usufruitier, duree_usufruit_temporaire, gestionnaire, dureedubail, expected_actability)
    lot_ids = rows.xpath("//tr/@id").map(&:value)
    i = 0
    rows.each do |row|
      disponibilite = row.at_xpath("td[14]").inner_html
      disponibilite = disponibilite.include?('success')

      lot_id = lot_ids[i]
      # save / update lot
      lot = Lot.where(
        site_id: site.id,
        programme_id: programme.id,
        lot_source_id: lot_id,
        programme_source_id: programme.source_id
      ).first_or_create

      lot.enabled = true
      lot.expected_actability = expected_actability
      lot.logements = logements
      lot.pleine_propriete = pleine_propriete
      lot.usufruitier = usufruitier
      lot.duree_usufruit_temporaire = duree_usufruit_temporaire
      lot.gestionnaire = gestionnaire
      lot.dureedubail = dureedubail

      puts "--------------------------"
      puts "lot #{i+1}: id #{lot_id}"
      reference = row.at_xpath("td[1]").inner_text
      puts "reference: #{reference}"
      lot_type = row.at_xpath("td[2]").inner_text
      puts "lot_type: #{lot_type}"

      # floor Rez de chaussée = ground floor = 0
      etage = row.at_xpath("td[3]").inner_text.split(' ').first.to_i
      puts "etage: #{etage}"

      # superficie = size
      superficie = row.at_xpath("td[4]").inner_text
      puts "superficie: #{superficie}"
      size = superficie.split(' ').first.sub('.', '').sub(',', '.').to_f
      puts "size: #{size}"

      terrasse_text = row.at_xpath("td[5]").inner_html
      puts "terrasse_text: #{terrasse_text}"

      price_without_construction = row.at_xpath("td[6]").inner_text
      puts "price_without_construction: #{price_without_construction}"

      additional_price_construction = row.at_xpath("td[7]").inner_text
      puts "additional_price_construction: #{additional_price_construction}"

      parking_price = row.at_xpath("td[8]").inner_text
      puts "parking_price: #{parking_price}"

      cellar_price = row.at_xpath("td[9]").inner_text
      puts "cellar_price: #{cellar_price}"

      price_text = row.at_xpath("td[10]").inner_text
      puts "price_text: #{price_text}"
      price = price_text.delete('€').delete(' ').to_i
      puts "price: #{price}"

      subsidy = row.at_xpath("td[11]").inner_text
      puts "subsidy: #{subsidy}"

      market_rental = row.at_xpath("td[12]").inner_text
      puts "market_rental: #{market_rental}"

      expected_delivery = row.at_xpath("td[13]").inner_text
      puts "expected_delivery: #{expected_delivery}"

      puts "disponibilite: #{disponibilite}"

      lot.images = programme.images
      lot.city_text = ville_postal_code
      lot.ville = ville
      lot.postal_code = postal_code
      lot.department = lot.postal_code.first(2)
      lot.region = region_for(lot.department)
      lot.zone = zone
      lot.fiscalite = fiscalite

      lot.reference = reference
      lot.lot_type = lot_type
      lot.etage = etage
      lot.superficie = superficie
      lot.size = size
      lot.terrasse_text = terrasse_text
      lot.price_text = price_text
      lot.price = price

      lot.price_without_construction = price_without_construction
      lot.additional_price_construction = additional_price_construction
      lot.parking_price = parking_price
      lot.cellar_price = cellar_price
      lot.subsidy = subsidy

      lot.expected_delivery = expected_delivery
      lot.disponibilite = disponibilite ? 'Yes' : 'No'
      lot.save

      @lots_count += 1

      i += 1
    end
  end

  def parse_lots_new(rows, programme, ville_postal_code, postal_code, ville, fiscalite, zone, logements, pleine_propriete, usufruitier, duree_usufruit_temporaire, gestionnaire, dureedubail, expected_actability)
    lot_ids = rows.xpath("//tr/@id").map(&:value)
    i = 0
    rows.each do |row|
      disponibilite = row.at_xpath("td[14]").inner_html
      disponibilite = disponibilite.include?('success')

      lot_id = lot_ids[i]
      # save / update lot
      lot = Lot.where(
        site_id: site.id,
        programme_id: programme.id,
        lot_source_id: lot_id,
        programme_source_id: programme.source_id
      ).first_or_create

      lot.enabled = true
      lot.expected_actability = expected_actability
      lot.logements = logements
      lot.pleine_propriete = pleine_propriete
      lot.usufruitier = usufruitier
      lot.duree_usufruit_temporaire = duree_usufruit_temporaire
      lot.gestionnaire = gestionnaire
      lot.dureedubail = dureedubail

      puts "--------------------------"
      puts "lot #{i+1}: id #{lot_id}"
      reference = row.at_xpath("td[1]").inner_text
      puts "reference: #{reference}"
      lot_type = row.at_xpath("td[2]").inner_text
      puts "lot_type: #{lot_type}"

      # floor Rez de chaussée = ground floor = 0
      etage = row.at_xpath("td[3]").inner_text.split(' ').first.to_i
      puts "etage: #{etage}"

      # superficie = size
      superficie = row.at_xpath("td[4]").inner_text
      puts "superficie: #{superficie}"
      size = superficie.split(' ').first.sub('.', '').sub(',', '.').to_f
      puts "size: #{size}"

      terrasse_text = row.at_xpath("td[5]").inner_html
      puts "terrasse_text: #{terrasse_text}"

      price_without_vat_exclude_furniture = row.at_xpath("td[6]").inner_text
      puts "price_without_vat_exclude_furniture: #{price_without_vat_exclude_furniture}"

      price_text = row.at_xpath("td[7]").inner_text
      puts "price_text: #{price_text}"
      price = price_text.delete('€').delete(' ').to_i
      puts "price: #{price}"

      parking_text = row.at_xpath("td[8]").inner_text
      puts "parking_text: #{parking_text}"

      loyer_ht = row.at_xpath("td[9]").inner_text
      puts "loyer_ht: #{loyer_ht}"

      # market_rental = row.at_xpath("td[10]").inner_text
      # puts "market_rental: #{market_rental}"

      rentabilite = row.at_xpath("td[10]").inner_text
      puts "rentabilite: #{rentabilite}"

      price_of_furniture_exclude_vat = row.at_xpath("td[11]").inner_text
      puts "price_of_furniture_exclude_vat: #{price_of_furniture_exclude_vat}"

      total_price_exclude_vat = row.at_xpath("td[12]").inner_text
      puts "total_price_exclude_vat: #{total_price_exclude_vat}"

      # pinel_rental = row.at_xpath("td[10]").inner_text
      # puts "pinel_rental: #{pinel_rental}"

      # pinel_rentabilite = row.at_xpath("td[11]").inner_text
      # puts "pinel_rentabilite: #{pinel_rentabilite}"

      expected_delivery = row.at_xpath("td[13]").inner_text
      puts "expected_delivery: #{expected_delivery}"

      puts "disponibilite: #{disponibilite}"

      lot.images = programme.images
      lot.city_text = ville_postal_code
      lot.ville = ville
      lot.postal_code = postal_code
      lot.department = lot.postal_code.first(2)
      lot.region = region_for(lot.department)
      lot.zone = zone
      lot.fiscalite = fiscalite
      lot.reference = reference
      lot.lot_type = lot_type
      lot.etage = etage
      lot.superficie = superficie
      lot.size = size
      lot.terrasse_text = terrasse_text
      lot.price_text = price_text
      lot.price = price
      lot.parking_text = parking_text
      lot.loyer_ht = loyer_ht
      lot.rentabilite = rentabilite
      lot.price_without_vat_exclude_furniture = price_without_vat_exclude_furniture
      lot.price_of_furniture_exclude_vat = price_of_furniture_exclude_vat
      lot.total_price_exclude_vat = total_price_exclude_vat
      lot.expected_delivery = expected_delivery
      lot.disponibilite = disponibilite ? 'Yes' : 'No'
      lot.save

      @lots_count += 1

      i += 1
    end
  end

  def login(session)
    session.post(
      "https://altareacogedim-partenaires.com/wp-login.php",
      "log" => "romeo.maike@fiduce.fr",
      "pwd" => "Jesuiscogedim1@",
      "redirect_to" => "/",
      "wp-submit" => ""
    )
  end
end
