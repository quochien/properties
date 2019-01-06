class Scrapers::BaseScraper
  def site_name
    raise NotImplementedError, "must be implemented in child class"
  end

  def site
    @site ||= Site.find_by(site_name: site_name)
  end
end
