class LotDatatable < BaseDatatable
  def view_columns
    @view_columns ||= {
      id: { source: "Lot.id" },
      lot_name: { source: "Lot.lot_name" },
      reference: { source: "Lot.reference" },
      lot_type: { source: "Lot.lot_type" },
      size: { source: "Lot.size" },
      etage: { source: "Lot.etage" },
      zone: { source: "Lot.zone" },
      fiscalite: { source: "Lot.fiscalite" },
      terrasse_text: { source: "Lot.terrasse_text" },
      parking_text: { source: "Lot.parking_text" },
      ville: { source: "Lot.ville" },
      postal_code: { source: "Lot.postal_code" },
      department: { source: "Lot.department" },
      region: { source: "Lot.region" },
      expected_delivery: { source: "Lot.expected_delivery" },
      expected_actability: { source: "Lot.expected_actability" },
      price: { source: "Lot.price" },
      disponibilite: { source: "Lot.disponibilite" },
      notary_fee: { source: "Lot.notary_fee" },
      security_deposit: { source: "Lot.security_deposit" },
      images: { source: "Lot.images" },
      actions: {},
    }
  end

  def data
    records.includes(:site).map do |lot|
      {
        id: lot.id,
        logo: image_tag(lot.site.logo, width: 40, height: 30).html_safe,
        reference: "n° #{lot.reference}".html_safe,
        lot_type: lot.lot_type,
        size: "#{lot.size} m2",
        etage: lot.etage == 1 ? "1 er" : "#{lot.etage} ème",
        zone: lot.zone,
        fiscalite: lot.fiscalite,
        terrasse_text: lot.terrasse_text&.html_safe,
        parking_text: lot.parking_text,
        ville: lot.ville,
        postal_code: lot.postal_code,
        department: lot.department,
        region: lot.region,
        expected_delivery: lot.expected_delivery&.html_safe,
        expected_actability: lot.expected_actability&.html_safe,
        price: "#{lot.price_text}",
        disponibilite: lot.disponibilite,
        notary_fee: lot.notary_fee,
        security_deposit: lot.security_deposit,
        logements: lot.logements,
        images: display_images(lot),
        actions: "",
      }
    end
  end

  private

  def get_raw_records
    Lot.all
  end

  def display_images(lot)
    return unless lot.images.present?

    html_images = []
    lot.images.split(';').each_with_index do |image, i|
      html_images << "<a style=\"visibility:hidden;\" href=\"#{image}\" data-lightbox=\"lot#{lot.id}\">Image_#{i+1}</a>"
    end
    html_images.join(" ").html_safe
  end
end
