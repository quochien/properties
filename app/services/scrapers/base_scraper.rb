class Scrapers::BaseScraper
  def site_name
    raise NotImplementedError, "must be implemented in child class"
  end

  def site
    @site ||= Site.find_by(site_name: site_name)
  end

  def region_for(department)
    return 'Auvergne-Rhône-Alpes' if %W[03 63 15 42 43 69 01 07 38 73 74].include? department
    return 'Bourgogne-Franche-Comté' if %W[89 58 71 21 25 39 70].include? department
    return 'Bretagne' if %W[22 29 35 56].include? department
    return 'Centre' if %W[28 37 41 45 18 36].include? department
    return 'Corse' if %W[2A 2B].include? department
    return 'Grand Est' if %W[08 10 51 52 54 55 57 67 68 88].include? department
    return 'Hauts-de-France' if %W[62 80 60 02 59].include? department
    return 'Île-de-France' if %W[75 77 78 91 92 93 94 95].include? department
    return 'Normandie' if %W[50 14 61 27 76].include? department
    return 'Nouvelle-Aquitaine' if %W[17 79 86 16 87 23 33 24 19 67 40 47].include? department
    return 'Occitanie' if %W[65 32 82 46 31 81 12 09 11 34 66 30 48].include? department
    return 'Pays de la Loire' if %W[44 53 85 49 72].include? department
    return "Provence-Alpes-Côte d'Azur" if %W[13 84 05 83 04 06].include? department
  end
end
