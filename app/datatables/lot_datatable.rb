class LotDatatable < BaseDatatable
  def view_columns
    @view_columns ||= {
      id: { source: "Lot.id" },
      lot_name: { source: "Lot.lot_name" },
      terrasse_text: { source: "Lot.terrasse_text" },
      parking_text: { source: "Lot.parking_text" },
      city_text: { source: "Lot.city_text" },
      expected_delivery: { source: "Lot.expected_delivery" },
      expected_actability: { source: "Lot.expected_actability" },
      price_text: { source: "Lot.price_text" },
      notary_fee: { source: "Lot.notary_fee" },
      security_deposit: { source: "Lot.security_deposit" },
      images: { source: "Lot.images" },
    }
  end

  def data
    records.includes(:site).map do |lot|
      {
        id: lot.id,
        logo: image_tag(lot.site.logo, width: 80, height: 60).html_safe,
        lot_name: "#{lot.lot_name}<br/>#{lot.full_desc}".html_safe,
        terrasse_text: lot.terrasse_text,
        parking_text: lot.parking_text,
        city_text: lot.city_text,
        expected_delivery: lot.expected_delivery,
        expected_actability: lot.expected_actability&.html_safe,
        price_text: lot.price_text,
        notary_fee: lot.notary_fee,
        security_deposit: lot.security_deposit,
        images: dispay_images(lot.images),
      }
    end
  end

  def get_raw_records
    Lot.all
  end

  private

  def dispay_images(images)
    html_images = []
    images.split(';').each_with_index do |image, i|
      html_images << "<a href=\"#{image}\" target=\"_blank\">Image_#{i+1}</a>"
    end
    html_images.join(" ").html_safe
  end
end
