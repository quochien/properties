class Scrapers::Nexity < Scrapers::BaseScraper
  def initialize
    @lots_count = 0
  end

  def site_name
    'nexity'
  end

  def perform
    Lot.where(site_id: site.id).update_all(enabled: false)

    puts "start scraping #{site.url}"
    session = Mechanize.new

    puts "login"
    login(session)

    page = session.get('https://monbookimmo.fr/Recherche/RechercheLot/Recherche')
    puts page.title
  end

  private

  def login(session)
    page = session.get('https://monbookimmo.fr')
    puts page.title

    page = session.post(
      'https://monbookimmo.fr/Authentification/Connexion/AuthentificationUtilisateur',
      'model.Login' => '998461',
      'model.Password' => 'Jenexity1@'
    )
  end
end
