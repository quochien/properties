class Scrapers::Nexity < Scrapers::BaseScraper
  def initialize
    @lots_count = 0
  end

  def site_name
    'nexity'
  end

  def perform
    Lot.where(site_id: site.id).update_all(enabled: false)
  end
end
