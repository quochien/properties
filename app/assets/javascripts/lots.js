jQuery(document).ready(function() {
  lightbox.init();

  var lotsTable = $('#lots-datatable').DataTable({
    "processing": true,
    "serverSide": true,
    "ajax": $('#lots-datatable').data('source'),
    "pagingType": "full_numbers",
    "columns": [
      {"data": "id"},
      {"data": "logo", "orderable": false, "searchable": false},
      {"data": "reference"},
      {"data": "lot_type"},
      {"data": "size"},
      {"data": "etage"},
      {"data": "zone"},
      {"data": "fiscalite"},
      {"data": "terrasse_text"},
      {"data": "parking_text"},
      {"data": "ville"},
      {"data": "postal_code"},
      {"data": "department"},
      {"data": "region"},
      {"data": "expected_delivery"},
      {"data": "expected_actability"},
      {"data": "price"},
      {"data": "disponibilite"},
      {"data": "notary_fee"},
      {"data": "security_deposit"},
      {"data": "images", "orderable": false, "searchable": false},
      {"data": "actions", visible: false, "orderable": false, "searchable": false},
    ]
  });

  $('#lots-datatable tbody').on('click', 'tr', function() {
    var data = lotsTable.row(this).data();
    lightbox.start($(data.images));
  });
});
