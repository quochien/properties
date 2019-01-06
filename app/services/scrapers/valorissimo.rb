class Scrapers::Valorissimo < Scrapers::BaseScraper
  def initialize
    @programme_ids = {}
    @lots_count = 0
  end

  def site_name
    'valorissimo'
  end
end
