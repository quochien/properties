# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
sites = [
  {
    site_name: 'icade-prescripteurs', url: 'http://www.icade-prescripteurs.com'
  },
  {
    site_name: 'valorissimo', url: 'https://www.valorissimo.com'
  }
]
sites.each do |site|
  Site.where(site_name: site[:site_name], url: site[:url]).first_or_create
end
