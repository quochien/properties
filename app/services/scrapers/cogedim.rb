class Scrapers::Cogedim < Scrapers::BaseScraper
  def initialize
    @programme_ids = {}
    @lots_count = 0
  end

  def site_name
    'cogedim'
  end

  def perform
    puts "start scraping #{site.url}"
    session = Mechanize.new

    puts "login"
    home_page = session.get("#{site.url}/?rp=t")
    login(session)

    puts "get lots"


    puts "Processed: #{@lots_count} lots"

    true
  end

  private

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
