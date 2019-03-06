namespace :scrapers do
  task cogedim: :environment do
    Scrapers::Cogedim.new.perform
  end

  task icade: :environment do
    Scrapers::IcadePrescripteurs.new.perform
  end

  task valorissimo: :environment do
    Scrapers::Valorissimo.new.perform
  end

  task vinci: :environment do
    Scrapers::Vinci.new.perform
  end

  task nexity: :environment do
    Scrapers::Nexity.new.perform
  end
end
