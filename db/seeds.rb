# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
sites = [
  {
    site_name: 'icade-prescripteurs',
    url: 'http://www.icade-prescripteurs.com',
    logo: 'logo_icade.png'
  },
  {
    site_name: 'valorissimo',
    url: 'https://www.valorissimo.com',
    logo: 'logo_valorissimo.png'
  },
  {
    site_name: 'cogedim',
    url: 'https://altareacogedim-partenaires.com',
    logo: 'logo_cogedim.jpg'
  },
  {
    site_name: 'catellapatrimoine',
    url: 'http://www.catellapatrimoine.fr',
    logo: 'logo_catellapatrimoine.jpg'
  },
  {
    site_name: 'vinci',
    url: 'https://www.vinci-immobilier-patrimoine.com',
    logo: 'logo_vinci.png'
  }
]
sites.each do |record|
  if site = Site.find_by(site_name: record[:site_name])
    site.url = record[:url]
    site.logo = record[:logo]
    site.save
  else
    Site.create(record)
  end
end
