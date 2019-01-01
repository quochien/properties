class Scrapers::BaseScraper
  def url
    raise NotImplementedError, "must be implemented in child class"
  end
end
