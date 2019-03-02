# Setup
Ruby version: 2.4.1

```
bundle install

rails db:migrate

rails db:seed

rails server
```

# Scrapers

## Cogedim

`Scrapers::Cogedim.new.perform`

## IcadePrescripteurs

`Scrapers::IcadePrescripteurs.new.perform`

## Valorissimo

`Scrapers::Valorissimo.new.perform`

## Vinci

`Scrapers::Vinci.new.perform`

# Website

Access `http://localhost:3000` to show the lots page
